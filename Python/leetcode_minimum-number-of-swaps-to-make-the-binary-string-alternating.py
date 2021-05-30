class Solution:
    def countX(self, lst, x):
        lst = [lst[i:i + 1] for i in range(len(lst))]
        return lst.count(x)

    def minSwaps(self, s: str) -> int:
        theValue = 0
        cToO = cToZ = len(s)

        compareStringOne = ''.join(["1" if x % 2 else "0" for x in range(0, len(s))])
        compareStringZero =  ''.join(["0" if  x % 2 else "1" for x in range(0,len(s))])

        oneCount = self.countX(s, "1")
        zeroCount = self.countX(s, "0")

        if oneCount == zeroCount or oneCount -1 == zeroCount or oneCount == zeroCount -1:
            for ch in range(len(s)):
                if s[ch] == compareStringOne[ch]:
                    cToO -= 1
                elif s[ch] == compareStringZero[ch]:
                    cToZ -= 1
        xV = [cToO,cToZ]
        xV = sorted(xV)

        for i in range(len(xV),0,-1):
            if xV[i-1] != 1 and (xV[i-1] % 2 == 0):
                theValue = xV[i-1]

        if cToO + cToZ != len(s):
            theValue = -1
        else:
            theValue = int(theValue/2)
        print(s, cToO, cToZ, theValue,len(s))

        return theValue

#tests = ["1110","111","100","010101011","0011","000111","0","1","01","10","0000011111","111000","11111000000","00011","000111"]
tests = ["1110","111","100","010101011","111000","11111000000","00011","000111"]
#tests = ["00011110110110000000000110110101011101111011111101010010010000000000000001101101010010001011110000001101111111110000110101101101001011000011111011101101100110011111110001100110001110000000001100010111110100111001001111100001000110101111010011001"]
for t in tests:
    the = Solution().minSwaps(t)
    print("\n")