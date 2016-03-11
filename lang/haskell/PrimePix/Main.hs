
module Main where

import Codec.Picture
import Data.List
import Test.QuickCheck

-- Ordered list difference.
minus
  :: (Ord a)
  => [a]
  -> [a]
  -> [a]
minus (x:xs) (y:ys)
    = case (compare x y) of 
        LT -> x : minus xs (y:ys)
        EQ ->     minus xs ys 
        GT ->     minus (x:xs) ys
minus xs _
    = xs

prop_minus
  :: (Ord a)
  => [a]
  -> [a]
  -> Bool
prop_minus xs ys
    = xs `minus` ys == xs \\ ys && zs `minus` xs == ys && zs \\ xs == ys
  where
    zs = xs ++ ys

renderer
  :: [Int]
  -> Int
  -> Int
  -> Int
  -> PixelRGB8
renderer primes width x y
    = PixelRGB8 0 g 0
  where
    i = width * y + x
    g = if i `elem` primes
          then 255
          else 0

-- Find all prime numbers up to m, in a slow, but easy to
-- understand, way.
primesTo
  :: Int
  -> [Int]
primesTo m
    | m > 4
    = sieve (2 : [3, 5..m])
    | otherwise
    = error "primesTo: to small value for m"
  where
    sieve (p:xs) = p : sieve [x | x <- xs, x `rem` p > 0]
    sieve []     = []

-- Compare the primesTo generator to the result of a third
-- party prime number generator.
prop_primesTo
  :: Bool
prop_primesTo
    = primesTo 1000 == [
          2,   3,   5,   7,  11,  13,  17,  19,  23,  29,
         31,  37,  41,  43,  47,  53,  59,  61,  67,  71,
         73,  79,  83,  89,  97, 101, 103, 107, 109, 113,
        127, 131, 137, 139, 149, 151, 157, 163, 167, 173,
        179, 181, 191, 193, 197, 199, 211, 223, 227, 229,
        233, 239, 241, 251, 257, 263, 269, 271, 277, 281,
        283, 293, 307, 311, 313, 317, 331, 337, 347, 349,
        353, 359, 367, 373, 379, 383, 389, 397, 401, 409,
        419, 421, 431, 433, 439, 443, 449, 457, 461, 463,
        467, 479, 487, 491, 499, 503, 509, 521, 523, 541,
        547, 557, 563, 569, 571, 577, 587, 593, 599, 601,
        607, 613, 617, 619, 631, 641, 643, 647, 653, 659,
        661, 673, 677, 683, 691, 701, 709, 719, 727, 733,
        739, 743, 751, 757, 761, 769, 773, 787, 797, 809,
        811, 821, 823, 827, 829, 839, 853, 857, 859, 863,
        877, 881, 883, 887, 907, 911, 919, 929, 937, 941,
        947, 953, 967, 971, 977, 983, 991, 997
      ]

-- Unbounded Euler's sieve.
primesUnboundEuler
  :: [Int]
primesUnboundEuler
    = 2 : eulers [3, 5..]
  where
    eulers (p:xs) = p : eulers (xs `minus` map (p*) (p:xs))

prop_primesUnboundEuler
  :: Bool
prop_primesUnboundEuler
    = take (length ps) primesUnboundEuler == ps
  where
    ps = primesTo 1000

width :: Int
width = 800

height :: Int
height = 600

primes :: [Int]
primes = primesTo (width * height)

main
  :: IO ()
main = do
    writePng "ppix.png" $ generateImage (renderer primes width) width height


