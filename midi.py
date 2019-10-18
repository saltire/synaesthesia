import alsaseq


CLIENT = 24

alsaseq.client('Simple', 1, 1, False)
alsaseq.connectfrom(0, CLIENT, 0)

while True:
    if alsaseq.inputpending():
        print(alsaseq.input())
