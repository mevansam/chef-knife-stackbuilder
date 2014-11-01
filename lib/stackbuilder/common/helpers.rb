# Copyright (c) 2014 Mevan Samaratunga

module StackBuilder::Common

    module Helpers

        #
        # Returns whether platform is a nix OS
        #
        def is_nix_os
            return RbConfig::CONFIG["host_os"] =~ /linux|freebsd|darwin|unix/
        end
        
        #
        # Runs the given execution list asynchronously if fork is supported
        #
        def exec_forked(exec_list)
            
            if is_nix_os
                p = []
                exec_list.each do |data|
                    p << fork {
                        yield(data)
                    }
                end
                p.each { |pid| Process.waitpid(pid) }
            else
                exec_list.each do |data|
                    yield(data)
                    printf("\n")
                end
            end
            
        end

        # 
        # Merges values of keys of to maps
        #        
        def merge_maps(map1, map2)
            
            map2.each_pair do |k, v2|
                
                v1 = map1[k]
                if v1.nil? 
                    if v2.is_a?(Hash)
                        v1 = { }
                        merge_maps(v1, v2)
                    elsif v2.is_a?(Array)
                        v1 = [ ] + v2
                    else
                        v1 = v2
                    end
                    map1[k] = v1
                elsif v1.is_a?(Hash) && v2.is_a?(Hash)
                    merge_maps(v1, v2)
                elsif v1.is_a?(Array) && v2.is_a?(Array)
                    
                    if v2.size > 0
                    
                        if v1.size > 0 && v1[0].is_a?(Hash) && v2[0].is_a?(Hash)
                            
                            i = 0
                            while i < [ v1.size, v2.size ].max do
                                
                                v1[i] = { } if v1[i].nil?
                                v2[i] = { } if v2[i].nil?
                                merge_maps(v1[i], v2[i])
                                
                                i += 1
                            end
                        
                        else
                            v1 += v2
                        end
                    end
                else
                    map1[k] = v2
                end 
            end
        end

        #
        # Evaluates map values against the
        # given map of environment variables
        #
        def evalMapValues(map, env)

            map.each_key do |k|

                v = map[k]

                if v.is_a?(String)
                    map[k] = eval("\"#{v}\"")

                elsif v.is_a?(Array)
                    map[k] =  v.map { |vv| eval("\"#{vv}\"") }

                elsif v.is_a?(Hash)
                    evalMapValues(v, env)

                end
            end
        end

        #
        # Prints a 2-d array within a table formatted to terminal size
        #
        def print_table(table, format = true, cols = nil)
            
            # Apply column filter
            unless cols.nil?
                
                headings = cols.split(",").to_set
                
                cols_to_delete = [ ]
                i = 0
                table[0].each do |col|
                    cols_to_delete << i unless headings.include?(col)
                    i = i + 1
                end
                
                table.each do |row|
                    cols_to_delete.reverse_each { |j| row.delete_at(j) }
                end
            end
            
            if format
                
                # Calculate widths
                widths = []
                table.each do |line|
                    c = 0
                    line.each do |col|
                        
                        len = col.nil? ? 0 : col.length
                        widths[c] = (widths[c] && widths[c] > len) ? widths[c] : len
                        c += 1
                    end
                end
                
                max_scr_cols = HighLine::SystemExtensions.terminal_size[0].nil? ? 9999 
                    : HighLine::SystemExtensions.terminal_size[0] - (widths.length * 3) - 2
                    
                max_tbl_cols = 0
                width_map = {}
                
                c = 0
                widths.each do |n| 
                    max_tbl_cols += n
                    width_map[c] = n
                    c += 1
                end
                c = nil
    
                # Shrink columns that have too much space to try and fit table into visible console
                if max_tbl_cols > max_scr_cols
                    
                    width_map = width_map.sort_by { |col,width| -width }
                    
                    last_col = widths.length - 1
                    c = 0
                    
                    while max_tbl_cols > max_scr_cols && c < last_col
                        
                        while width_map[c][1] > width_map[c + 1][1]
                            
                            i = c
                            while i >= 0
                                width_map[i][1] -= 1
                                widths[width_map[i][0]] -= 1
                                max_tbl_cols -= 1
                                i -= 1
                                
                                break if max_tbl_cols == max_scr_cols
                            end
                            break if max_tbl_cols == max_scr_cols
                        end
                        c += 1
                    end
                end
                
                border1 = ""
                border2 = ""
                format = ""
                widths.each do |n|
                    
                    border1 += "+#{'-' * (n + 2)}"
                    border2 += "+#{'=' * (n + 2)}"
                    format += "| %#{n}s "
                end
                border1 += "+\n"
                border2 += "+\n"
                format += "|\n"
                
            else
                c = nil
                border1 = nil
                border2 = nil
                
                format = Array.new(table[0].size, "%s,").join.chop! + "\n"
                
                # Delete column headings for unformatted output
                table.delete_at(0)
            end
            
            # Print each line.
            write_header_border = !border2.nil?
            printf border1 if border1
            table.each do |line|
                
                if c
                    # Check if cell needs to be truncated
                    i = 0
                    while i < c
                        
                        j = width_map[i][0]
                        width = width_map[i][1]
                        
                        cell = line[j]
                        len = cell.length
                        if len > width
                            line[j] = cell[0, width - 2] + ".."
                        end
                        i += 1
                    end
                end
                
                printf format, *line
                if write_header_border
                    printf border2
                    write_header_border = false
                end
            end
            printf border1 if border1

        end

        def run_knife(knife_cmd)

            error = StringIO.new
            output = StringIO.new

            knife_cmd.ui = Chef::Knife::UI.new(output, error, STDIN, {})
            knife_cmd.run

            raise KnifeError, error.string if error.size>0
            output.string
        end

    end

end