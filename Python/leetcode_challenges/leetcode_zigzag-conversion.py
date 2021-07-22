class Solution:
    def convert(self, s: str, numRows: int):
        _foward = False
        # make row logic
        theValue = [""] * numRows
        for v in range(0,len(s[:numRows]),1):
            theValue[v]=(s[v])
        cnt = numRows - 1
        for ch in range(numRows,len(s),1):
            if cnt == 0:
                _foward = True
            elif cnt == numRows - 1:
                _foward = False
            if not _foward:
                cnt -= 1
            else:
                cnt += 1

            if numRows == 1:
                cnt = 0

            theValue[cnt] += s[ch]

        theValue = ''.join(theValue)
        return theValue

if __name__ == '__main__':
    #string = "A"
    string = "1234567"
    #string = "ABC"
    #print(len(string))
    print(Solution().convert(string,numRows=3))