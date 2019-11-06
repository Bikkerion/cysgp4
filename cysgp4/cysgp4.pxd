#!/usr/bin/python
# -*- coding: utf-8 -*-

# ####################################################################
#
# title                  :cysgp4.pxd
# description            :Cython-powered wrapper of the sgp4lib library
# author                 :Benjamin Winkel
#
# ####################################################################
#  Copyright (C) 2014+ by Benjamin Winkel
#  bwinkel@mpifr.de
#  This file is part of cysgp4.
#
#  cysgp4 is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software Foundation,
#  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
#
# Note: cyaatm is a wrapper around sgp4lib library by Daniel Warner
#       (see package in cextern directory).
# ####################################################################

cimport cython
from cython.operator cimport dereference as deref, preincrement as inc
from libcpp.string cimport string
from libcpp cimport bool


cdef extern from 'Tle.h':

    cdef cppclass Tle:

        Tle(
            const string & name,
            const string & line_one,
            const string & line_two
            ) nogil except +
        string ToString() nogil const
        string Name() nogil const
        string Line1() nogil const
        string Line2() nogil const


cdef extern from 'SGP4.h':

    cdef cppclass SGP4:
        SGP4(const Tle& tle) nogil except +

        Eci FindPosition(const DateTime& date) nogil const


cdef extern from 'Observer.h':

    cdef cppclass Observer:

        Observer(
            const double latitude,
            const double longitude,
            const double altitude
            ) nogil except +
        Observer(const CoordGeodetic &geo) nogil except +
        CoordTopocentric GetLookAngle(const Eci &eci) nogil
        void SetLocation(const CoordGeodetic& geo) nogil
        CoordGeodetic GetLocation() nogil const


cdef extern from 'Vector.h':

    cdef cppclass Vector:

        Vector() nogil except +
        Vector(
            const double arg_x, const double arg_y, const double arg_z
            ) nogil except +

        double x
        double y
        double z


cdef extern from 'DateTime.h':

    cdef cppclass DateTime:

        DateTime() nogil except +
        DateTime(unsigned long long ticks) nogil except +
        void Initialise(
            int year, int month, int day,
            int hour, int minute, int second, int microsecond
            ) nogil
        double ToGreenwichSiderealTime() nogil const
        double ToLocalMeanSiderealTime(const double lon) nogil const
        string ToString() nogil const
        DateTime AddTicks(long long ticks) nogil const
        long long Ticks() nogil const

    # how to wrap static c++ member functions???
    # cdef DateTime_Now 'DateTime::Now' (bool microseconds)


# cdef extern from 'DateTime.h' namespace 'DateTime':
    # DateTime Now(bool microseconds)


cdef extern from 'Eci.h':

    cdef cppclass Eci:

        Eci() nogil except +
        Eci(
            const DateTime& dt, const double latitude, const double longitude,
            const double altitude
            ) nogil except +
        Eci(const DateTime& dt, const CoordGeodetic& geo) nogil except +
        DateTime GetDateTime() nogil const
        CoordGeodetic ToGeodetic() nogil const
        Vector Position() nogil const
        Vector Velocity() nogil const


cdef extern from 'CoordTopocentric.h':

    cdef cppclass CoordTopocentric:

        CoordTopocentric() nogil except +
        CoordTopocentric(const CoordTopocentric& topo) nogil except +
        CoordTopocentric(
            double az, double el, double rnge, double rnge_rate
            ) nogil except +
        string ToString() nogil const
        # azimuth in radians
        double azimuth
        # elevations in radians
        double elevation
        # distance in kilometers
        double distance 'range'
        # range rate in kilometers per second
        double distance_rate 'range_rate'



cdef extern from 'CoordGeodetic.h':

    cdef cppclass CoordGeodetic:

        CoordGeodetic() nogil except +
        CoordGeodetic(const CoordGeodetic& geo) nogil except +
        CoordGeodetic(
            double lat, double lon, double alt, bool is_radians=False
            ) nogil except +
        string ToString() nogil const
        # latitude in radians (-PI >= latitude < PI)
        double latitude
        # latitude in radians (-PI/2 >= latitude <= PI/2)
        double longitude
        # altitude in kilometers
        double altitude


# https://stackoverflow.com/questions/51006230/dynamically-sized-array-of-objects-in-cython
cdef extern from *:
    """
    template <typename T>
    T* array_new(int n) {
        return new T[n];
    }

    template <typename T>
    void array_delete(T* x) {
        delete [] x;
    }
    """
    T* array_new[T](int)
    void array_delete[T](T* x)
