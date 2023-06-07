import numpy as np

from src.game_of_life.core import GameOfLife
gol = GameOfLife(100)


# show by cv2
# import cv2
# while cv2.waitKey(1) != ord('q'):
#     cv2.imshow('game of life', np.asarray(gol))
#     gol.update()


# show by matplotlib
from matplotlib import pyplot as plt
plt.ion()
while 1:
    plt.imshow(np.asarray(gol), cmap='gray')
    plt.axis('off')
    plt.pause(0.01)
    plt.clf()
    gol.update()
