#!/usr/bin/env python3
"""
Description: Tabbed Notes Script for write and get data
Author: Daniel Córdova A.
E-Mail : danesc87@gmail.com
Github : @danesc87
Released under GPLv3
"""


class NotesHandler(object):
    _TITLE_TAG = '###'

    def __init__(self):
        from os.path import expanduser
        self.data = {}
        self.file_path = expanduser('~/.local/share/notes')

    def read_data(self):
        title = ''
        paged_data = ''
        try:
            file = open(self.file_path, 'r+')
        except FileNotFoundError:
            file = open(self.file_path, 'w+')

        with file as opened_file:
            for line in opened_file:
                data = line.strip().split('\n', 1)[0]
                if line == '\n':
                    continue
                if self._TITLE_TAG in line:
                    paged_data = ''
                    title = data.split(self._TITLE_TAG, 1)[1].strip()
                else:
                    paged_data += data.strip() + '\n'
                self.data[title] = paged_data
        file.close()

    def get_file_data(self):
        return self.data

    def write_data(self, data):
        file = open(self.file_path, 'w')
        file.write(data)
        file.close()


if __name__ == '__main__':
    from sys import argv, exit

    if len(argv) == 1 or len(argv) > 3:
        print(
            '''This script needs the following arguments:
            - action (READ,WRITE)
            - notes data'''
        )
        exit(1)
    notes_handler = NotesHandler()
    if argv[1].upper() == 'READ':
        import json
        notes_handler.read_data()
        print(json.dumps(notes_handler.get_file_data(), indent = 2))
    elif argv[1].upper() == 'WRITE':
        notes_handler.write_data(str(argv[2]))
    else:
        print('Argument: ' + str(argv[1]) + ' is not valid.\nMust be READ or WRITE!')
        exit(1)
