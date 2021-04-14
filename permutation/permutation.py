import logging
import copy
import fire

logger = logging.getLogger(__name__)


def _permute_line(line):
    if not line or not len(line):
        return

    result = []
    target = copy.copy(line)  # Make a shallow copy, avoid mutation on source

    def swap(a: int, b: int):
        target[a], target[b] = target[b], target[a]

    def permute(left_index: int, right_index: int):
        if left_index != right_index:
            for i in range(left_index, right_index + 1):
                swap(i, left_index)
                permute(left_index + 1, right_index)
                swap(i, left_index)
        else:
            result.append(''.join(target))

    def print_result():
        # Remove duplicated results in case of duplicated source
        sorted_result = sorted(list(set(result)))
        print(','.join(sorted_result))

    permute(0, len(target) - 1)
    print_result()


def permute_file(file_name: str):
    try:
        with open(file_name) as file:
            # Strip out spaces just in case
            source = [list(line.rstrip('\n').strip()) for line in file]
            for line in source:
                _permute_line(line)
    except Exception as e:
        logger.error(f'Failed to read file: {str(e)}')


if __name__ == '__main__':
    fire.Fire(permute_file)

# Code formatted with autopep8 by PyCharm
