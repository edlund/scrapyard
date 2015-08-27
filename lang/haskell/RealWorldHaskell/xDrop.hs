
-- A reimplementation of the standard drop function.

xDrop n xs = if n <= 0 || null xs
	then xs
	else xDrop (n - 1) (tail xs)

