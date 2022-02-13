import argparse


def main(file_path: str):
    with open(file_path, 'r') as f:
        lines = f.readlines()

    print(" ".join([line.rstrip() for line in lines]))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file_path')
    args = parser.parse_args()

    main(args.file_path)

