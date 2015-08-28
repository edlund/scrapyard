#!/usr/bin/env python

from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

x0 = -2.0
y0 = 1.0
x1 = 1.0
y1 = -1.0

w = 75
h = 36

n = 100
x_s = (x1 - x0) / w
y_s = (y1 - y0) / h;

esc = 2.0

y = y0

while y > y1:
	x = x0
	while x < x1:
		c = complex(x, y)
		z = complex(0, 0)
		i = 0
		x = x + x_s
		while abs(z) < esc and i < n:
			z = z * z + c
			i = i + 1
		print(" " if i < n else "#", end="")
	y = y + y_s
	print("")

