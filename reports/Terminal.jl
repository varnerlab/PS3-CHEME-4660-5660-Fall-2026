# Shared plain-text formatting for the checker and financial report.

"""
    print_terminal_text(text; prefix="", continuation=prefix, width=78) -> Nothing

Print text with word wrapping and optional hanging indentation. Preserve
explicit line breaks and split long words so each printed line fits `width`
display columns. Returns `nothing`; does not add color or terminal controls.
"""
function print_terminal_text(text::AbstractString; prefix::String="",
    continuation::String=prefix, width::Int=78)::Nothing
    for paragraph in split(text, '\n')
        line = prefix;
        has_word = false;
        for word in split(paragraph)
            if has_word && textwidth(line) + 1 + textwidth(word) > width
                println(rstrip(line));
                line = continuation;
                has_word = false;
            end
            has_word && (line *= " ");
            for character in word
                if textwidth(line) + textwidth(character) > width
                    println(rstrip(line));
                    line = continuation;
                end
                line *= string(character);
            end
            has_word = true;
        end
        println(rstrip(line));
    end
    return nothing;
end

"""
    print_terminal_detail(text; prefix="  ", width=78) -> Nothing

Print diagnostic text while preserving spaces and line breaks, including
Julia's source snippets and error pointers. Wrap long lines at spaces when
possible; split a long word only if it cannot fit within the display width.
Returns `nothing`.
"""
function print_terminal_detail(text::AbstractString; prefix::String="  ", width::Int=78)::Nothing
    for original in split(replace(text, '\t' => "    "), '\n')
        characters = collect(original);
        isempty(characters) && println();
        start = 1;
        while start <= length(characters)
            stop = start - 1;
            occupied = textwidth(prefix);
            while stop < length(characters) && occupied + textwidth(characters[stop+1]) <= width
                stop += 1;
                occupied += textwidth(characters[stop]);
            end
            if stop < length(characters)
                gap = findlast(isspace, characters[start:stop]);
                if gap !== nothing && any(c -> !isspace(c), characters[start:start+gap-2])
                    finish = start + gap - 2;
                    println(rstrip(prefix * join(characters[start:finish])));
                    start = finish + 2;
                    continue;
                end
            end
            println(rstrip(prefix * join(characters[start:stop])));
            start = stop + 1;
        end
    end
    return nothing;
end

"""
    print_terminal_section(title; major=false) -> Nothing

Print a separated heading. Major sections use a 78-column rule; smaller
sections use a rule matching the title. Returns `nothing`.
"""
function print_terminal_section(title::String; major::Bool=false)::Nothing
    println();
    major && println(repeat("=", 78));
    print_terminal_text(title);
    println(repeat(major ? "=" : "-", major ? 78 : min(textwidth(title), 78)));
    return nothing;
end

"""
    print_terminal_table(headers, rows; right_columns=Int[]) -> Nothing

Print a table of strings with aligned columns and a rule beneath its header.
Columns listed in `right_columns` are right aligned. If a table would exceed
78 columns, print each row as labeled values instead. Returns `nothing`.
"""
function print_terminal_table(headers::Vector{String}, rows::Vector{Vector{String}};
    right_columns::Vector{Int}=Int[])::Nothing
    widths = [maximum(textwidth, [headers[j]; [row[j] for row in rows]]) for j in eachindex(headers)];
    if sum(widths) + 3*(length(headers)-1) > 78
        for (index, row) in enumerate(rows)
            index > 1 && println();
            for (header, value) in zip(headers, row)
                print_terminal_text("$(header): $(value)"; prefix="  ");
            end
        end
        return nothing;
    end
    format_row = row -> join([j in right_columns ? lpad(row[j], widths[j]) :
        rpad(row[j], widths[j]) for j in eachindex(headers)], " | ");
    println(rstrip(format_row(headers)));
    println(join([repeat("-", width) for width in widths], "-+-"));
    for row in rows
        println(rstrip(format_row(row)));
    end
    return nothing;
end
