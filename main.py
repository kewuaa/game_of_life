import cv2
import numpy as np

from src.game_of_life.core import GameOfLife


gol = GameOfLife(300)
while cv2.waitKey(1) != ord('q'):
    cv2.imshow('game of life', np.asarray(gol))
    gol.update()
