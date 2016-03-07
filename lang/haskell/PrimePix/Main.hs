
module Main where

import Codec.Picture
import Data.List

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

primesTo
  :: Int
  -> [Int]
primesTo m
    = sieve [2..m]
  where
    sieve (p:xs) = p : sieve [x | x <- xs, x `rem` p > 0]
    sieve []     = []

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

