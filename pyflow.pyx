# distutils: language = c++
# distutils: sources = src/Coarse2FineFlowWrapper.cpp
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import numpy as np
cimport numpy as np
from libcpp cimport bool
# Author: Deepak Pathak (c) 2016

cdef extern from "src/Coarse2FineFlowWrapper.h":
    void Coarse2FineFlowWrapper(double * vx, double * vy, double * warpI2,
                                  const double * Im1, const double * Im2,
                                  double alpha, double ratio, int minWidth,
                                  int nOuterFPIterations, int nInnerFPIterations,
                                  int nSORIterations, int colType,
                                  int h, int w, int c, bool verbose, double threshold);
# cdef extern from "src/Coarse2FineFlowWrapper.h":
    void warpMaskFL(double *warpMask, const double *Mask,
                        const double *vx, const double *vy,
                        int colType, int h, int w, int c);

def coarse2fine_flow(np.ndarray[double, ndim=3, mode="c"] Im1 not None,
                        np.ndarray[double, ndim=3, mode="c"] Im2 not None,
                        double alpha=1, double ratio=0.5, int minWidth=40,
                        int nOuterFPIterations=3, int nInnerFPIterations=1,
                        int nSORIterations=20, int colType=0, 
                        bool verbose = False,
                        double threshold = 0.0):
    """
    Input Format:
      double * vx, double * vy, double * warpI2,
      const double * Im1 (range [0,1]), const double * Im2 (range [0,1]),
      double alpha (1), double ratio (0.5), int minWidth (40),
      int nOuterFPIterations (3), int nInnerFPIterations (1),
      int nSORIterations (20),
      int colType (0 or default:RGB, 1:GRAY)
    Images Format: (h,w,c): float64: [0,1]
    """
    cdef int h = Im1.shape[0]
    cdef int w = Im1.shape[1]
    cdef int c = Im1.shape[2]
    cdef np.ndarray[double, ndim=2, mode="c"] vx = \
        np.ascontiguousarray(np.zeros((h, w), dtype=np.float64))
    cdef np.ndarray[double, ndim=2, mode="c"] vy = \
        np.ascontiguousarray(np.zeros((h, w), dtype=np.float64))
    cdef np.ndarray[double, ndim=3, mode="c"] warpI2 = \
        np.ascontiguousarray(np.zeros((h, w, c), dtype=np.float64))
    Im1 = np.ascontiguousarray(Im1)
    Im2 = np.ascontiguousarray(Im2)

    Coarse2FineFlowWrapper(&vx[0, 0], &vy[0, 0], &warpI2[0, 0, 0],
                            &Im1[0, 0, 0], &Im2[0, 0, 0],
                            alpha, ratio, minWidth, nOuterFPIterations,
                            nInnerFPIterations, nSORIterations, colType,
                            h, w, c,
                            verbose,
                            threshold)
    return vx, vy, warpI2

def warp_mask_flow(np.ndarray[double, ndim=3, mode="c"] Mask not None,
                        np.ndarray[double, ndim=2, mode="c"] vx not None,
                        np.ndarray[double, ndim=2, mode="c"] vy not None,
                        int colType=1):
    """
    Input Format:
      double * vx, double * vy, double * warpI2,
      const double * Im1 (range [0,1]), const double * Im2 (range [0,1]),
      double alpha (1), double ratio (0.5), int minWidth (40),
      int nOuterFPIterations (3), int nInnerFPIterations (1),
      int nSORIterations (20),
      int colType (0 or default:RGB, 1:GRAY)
    Images Format: (h,w,c): float64: [0,1]
    """
    cdef int h = Mask.shape[0]
    cdef int w = Mask.shape[1]
    cdef int c = Mask.shape[2]
    cdef np.ndarray[double, ndim=3, mode="c"] warpMask = np.ascontiguousarray(np.zeros((h, w, c), dtype=np.float64))
    Mask = np.ascontiguousarray(Mask)
    vx = np.ascontiguousarray(vx)
    vy = np.ascontiguousarray(vy)
    warpMaskFL(&warpMask[0, 0, 0], &Mask[0, 0, 0], &vx[0, 0], &vy[0, 0], colType, h, w, c)
    return warpMask


