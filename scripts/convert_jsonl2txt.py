import json
import argparse

def convert_jsonl_to_txt(args):
    fr = open(args.input)
    fw = open(args.output, "w", encoding="utf-8")
    line = fr.readline()
    count = 0
    count_line = 0
    while line:
        if count % 10000 == 0:
            print(f"Extracted {count} paragraphs from {args.input}")
        data = json.loads(line)
        ## Filter adult and noisy contents
        if (data["metadata"]["annotation"] == None) or ("noisy" not in data["metadata"]["annotation"] and "adult" not in data["metadata"]["annotation"]):
            contents = data["content"].split("\n")
            identifications = data["metadata"]['sentence_identifications']
            assert len(contents) == len(identifications)
            for ind in range(len(contents)):
                if identifications[ind] != None and len(contents[ind]) > 5:
                    fw.writelines([contents[ind].strip(), "\n"])
                    count_line += 1
        line = fr.readline()
        count += 1
        if args.max_length > 0 and count_line >= args.max_length:
            break
    print(f"Total write {count_line} lines")
    fr.close()
    fw.close()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=str, required=True, help='input file')
    parser.add_argument('--output', type=str, required=True, help='output file')
    parser.add_argument('--max_length', type=int, default=-1, help='max length to extract')
    args = parser.parse_args()
    convert_jsonl_to_txt(args)

if __name__ == "__main__":
    main()
