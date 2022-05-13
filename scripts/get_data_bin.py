import argparse
import os

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=str, required=True, help='input file')
    args = parser.parse_args()
    databins = os.listdir(args.input)
    res = []
    for db in databins:
        if "databin" in db:
            res.append(args.input + "/" + db)
    res = ":".join(res)
    print(res)

if __name__ == "__main__":
    main()