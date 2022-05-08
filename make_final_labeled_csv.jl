# program arguments <ids csv> <tweets texts csv> <labels csv> <output csv>

function write_combined_csv(id_csv, text_csv, label_csv, output_csv)
    writer = open(output_csv, "w")

    id_lines = readlines(open(id_csv, "r"))
    text_lines = readlines(open(text_csv, "r"))
    label_lines = readlines(open(label_csv, "r"))

    for (id, text, label) in zip(id_lines, text_lines, label_lines)
        println(writer,"$id|$text|$label")
    end
end

function main()
    id_csv, text_csv, label_csv, output_csv = ARGS
    write_combined_csv(id_csv, text_csv, label_csv, output_csv)
end

main()