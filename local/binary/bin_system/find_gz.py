import sys, os


def finder(file: str, whatfind: str):
    with open(file, "rb") as f:
        return f.read().find(bytes.fromhex(whatfind))


def main(file, whatfind):
    offset = finder(file, whatfind)
    if offset >= 0:
        size = os.stat(file).st_size
        with open(file, 'rb') as f, open("kernel.gz", 'wb') as favb:
            f.seek(offset)
            favb.write(f.read(size - offset))
    return None


if __name__ == '__main__':
    if len(sys.argv) == 3:
        main(sys.argv[1], sys.argv[2])
