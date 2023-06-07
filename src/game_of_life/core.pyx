# cython: language_level=3
# cython: boundscheck=False
# cython: wraparound=False
# cython: cdivision=True
# distutils: language=c++
# distutils: define_macros=NPY_NO_DEPRECATED_API=NPY_1_7_API_VERSION
from cpython.mem cimport PyMem_Malloc, PyMem_Free, Py_buffer
from libc.stdlib cimport rand, srand
from libc.time cimport time
from libcpp.vector cimport vector
cimport numpy as cnp
ctypedef unsigned char uint8


cdef class GameOfLife:
    """生命游戏。"""

    cdef:
        size_t _N
        uint8* _data
        Py_ssize_t _shape[2]
        Py_ssize_t _strides[2]

    def __cinit__(self, size_t N) -> None:
        self._data = <uint8*>PyMem_Malloc(sizeof(uint8) * N * N)

    def __init__(self, size_t N) -> None:
        self._N = N
        self._shape[0] = self._shape[1] = N
        self._strides[1] = sizeof(uint8)
        self._strides[0] = N * self._strides[1]
        srand(<unsigned int>time(NULL))
        cdef size_t i
        for i in range(N * N):
            self._data[i] = rand() % 2 * 255

    def __getbuffer__(self, Py_buffer* buf, int flags) -> None:
        buf.buf = self._data
        buf.format = 'B'
        buf.internal = NULL
        buf.itemsize = sizeof(uint8)
        buf.len = self._N * self._N * buf.itemsize
        buf.ndim = 2
        buf.obj = self
        buf.readonly = 0
        buf.shape = self._shape
        buf.strides = self._strides
        buf.suboffsets = NULL

    def update(self) -> None:
        """更新细胞。"""

        cdef size_t num
        cdef size_t i, j
        cdef int k, l
        cdef vector[size_t] need_update_index
        need_update_index.reserve(self._N * self._N / 2)
        cdef size_t row, col, index
        for i in range(self._N):
            for j in range(self._N):
                num = 0
                for k in range(-1, 2):
                    for l in range(-1, 2):
                        row = i + k
                        col = j + l
                        if 0 < row < self._N and 0 < col < self._N:
                            if self._data[row + col * self._N]:
                                num += 1
                        index = i + j * self._N
                        if (num == 3 and not self._data[index]) \
                                or ((num < 3 or num > 4) and self._data[index]):
                            need_update_index.push_back(index)
        for i in range(need_update_index.size()):
            index = need_update_index[i]
            self._data[index] = 255 - self._data[index]

    def to_numpy(self) -> cnp.ndarray:
        """转换为 numpy 数组。"""

        cdef Py_ssize_t shape[2]
        shape[0] = self._N
        shape[1] = self._N
        cdef cnp.ndarray out = <cnp.ndarray>cnp.PyArray_SimpleNewFromData(
            2, &shape[0], cnp.NPY_UINT8, <void*>self._data
        )
        return out

    def __dealloc__(self) -> None:
        if self._data is not NULL:
            PyMem_Free(self._data)
