class Solution:
    def _check32Int(self, ch):
        if int(ch) >= pow(2, 31) - 1:
            return (pow(2, 31) - 1)
        elif int(ch) <= pow(-2, 31):
            return pow(-2, 31)
        else:
            return int(ch)

    def _chCheck(self, ch, listCheck=" 1234567890", approved=False):
        listCheck = [listCheck[i] for i in range(len(listCheck))]
        for ck in listCheck:
            if ck == ch:
                approved = True
        return approved

    def myAtoi(self, s: str) -> int:
        check = "-+ 1234567890"
        number = ""
        for ch in range(len(s)):
            vC = s[ch]
            if self._chCheck(vC, listCheck=check):
                number += vC
                if self._chCheck(vC, listCheck="-+1234567890"):
                    check = "1234567890"
            else:
                break

        number = number.replace(" ", "")

        if number == "-" or number == "+":
            number = ""

        if number != "":
            return self._check32Int(number)
        else:
            return 0


string = " +-"
string = "-+200"
string = "+2 200"
print(Solution().myAtoi(string))
