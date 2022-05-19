
"""
    write_combined_csv(id_csv::String, 
                       text_csv::String, 
                       label_csv::String, 
                       output_csv::String)

Write combined CSV to output_csv taking columns from id_csv, text_csv, & label_csv.

"""
function write_combined_csv(id_csv::String, 
                            text_csv::String, 
                            label_csv::String, 
                            output_csv::String)
    writer = open(output_csv, "w")

    id_lines = readlines(open(id_csv, "r"))
    text_lines = readlines(open(text_csv, "r"))
    label_lines = readlines(open(label_csv, "r"))

    for (id, text, label) in zip(id_lines, text_lines, label_lines)
        println(writer,"$id|$text|$label")
    end
end

""" Main function for taking in program arguments """
function main()
    # program arguments <ids csv> <tweets texts csv> <labels csv> <output csv>
    id_csv, text_csv, label_csv, output_csv = ARGS
    write_combined_csv(id_csv, text_csv, label_csv, output_csv)
end

main()