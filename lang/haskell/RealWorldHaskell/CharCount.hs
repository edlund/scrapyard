
-- Usage example: runghc CharCount < CharCount.hs

main = interact charCount
	where charCount input = show (length (input)) ++ "\n"

