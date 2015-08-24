
-- Usage example: runghc WordCount < WordCount.hs

main = interact wordCount
	where wordCount input = show (length (words input)) ++ "\n"

