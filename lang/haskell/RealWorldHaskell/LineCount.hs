
-- Usage example: runghc LineCount < LineCount.hs

main = interact lineCount
	where lineCount input = show (length (lines input)) ++ "\n"

