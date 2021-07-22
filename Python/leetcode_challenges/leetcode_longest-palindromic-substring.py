# 1st solution too slow
"""
class Solution:
    def longestPalindrome(self, s):
        ch = 0
        score = 0
        theValue = ""
        while True:
            testValue = ""
            size = len(s)
            for x in range(0, ch):
                testValue += s[x]
                reverse = testValue[:x + 1][::-1]
                # print(testValue)
                # print(reverse)
                if testValue == reverse and score < len(testValue):
                    score = len(testValue)
                    theValue = testValue
                print(theValue)
            if ch == len(s):
                s = s[-len(s) + 1:]
                ch = 0
            if 0 == size or size == 1:
                # print("end")
                break
            ch += 1
"""
# 2nd solution faster, but still rather slow
"""
class Solution:
    def longestPalindrome(self, s):
        theValue = ""
        score = 0
        size = 1
        if s[:len(s)] != s[:len(s)][::-1]:
            while size <= len(s):
                setLenght = s[:size]
                for x in range(len(setLenght), 0, -1):
                    if setLenght[:x] == setLenght[:x][::-1] and score < len(setLenght[:x]):
                        theValue = setLenght[:x]
                        score = len(setLenght[:x])
                    setLenght = setLenght[-len(setLenght) + 1:]
                size += 1
        else:
            theValue = s
        return theValue

    def longestPalindrome(self, s):
        theValue = ""
        score = 0
        size = 1
        if s[:len(s)] != s[:len(s)][::-1]:
            while size <= len(s):
                setLenght = s[:size]
                for x in range(len(setLenght), 0, -1):
                    if setLenght[:x] == setLenght[:x][::-1] and score < len(setLenght[:x]):
                        theValue = setLenght[:x]
                        score = len(setLenght[:x])
                    setLenght = setLenght[-len(setLenght) + 1:]
                size += 1
        else:
            theValue = s

"""
# 3rd solution faster than 2nd
class Solution:
    def longestPalindrome(self, s):
        theValue = "b"
        size = 0
        if s != s[::-1]:
            for ch in range(0, len(s), 1):
                i = ch
                j = ch + 1
                target = s[i:j]
                if target == target[::-1]:
                    for x in range(0, len(s) - ch, 1):
                        target = s[i:j+x]
                        if target == target[::-1] and len(target) > size:
                            size = len(target)
                            theValue = target
        else:
            theValue = s
        return theValue

if __name__ == '__main__':
    tests = ["aqwert","ffaswwabbaaabbaxzzxc","babad","abbabcca","abb","a","cbbd","aqwert"
             "xiqhechagdpbcdthaafmcnplenylepawbafsmxqlwhzgqmuemwolgoockcafchdsfggulwfzwwkvivnwgbelbbydzfkcfsschvbantskuosunhqihmqjmzgavfnonwhwrkfxgcbowfsebthbrhhklxxyoxiphrgxqodulrbbvdwcclpyjhljgyypztbqzkiyzbfnvnoargyyakaidkiyleurvjbadzwqjtrluayhblhdokmwrwhassruxpftwlbalfvwxtfcqibywsusrlwmbcibvgwnmmdmuhswuperbjoxarhqcpcebbtyhnrouvuwftspmzsmdhfcqovffkuikzrcweffmpnjldoalhcvqvjavllvajvqvchlaodljnpmffewcrzkiukffvoqcfhdmszmpstfwuvuornhytbbecpcqhraxojbrepuwshumdmmnwgvbicbmwlrsuswybiqcftxwvflablwtfpxurssahwrwmkodhlbhyaulrtjqwzdabjvruelyikdiakayygraonvnfbzyikzqbtzpyygjlhjyplccwdvbbrludoqxgrhpixoyxxlkhhrbhtbesfwobcgxfkrwhwnonfvagzmjqmhiqhnusoukstnabvhcssfckfzdybblebgwnvivkwwzfwluggfsdhcfackcooglowmeumqgzhwlqxmsfabwapelynelpncmfaahtdcbpdgahcehqix",
             "fkyidosnupvunmklebjiepwdmfhqjfjgtcdivzgibcewxviirtneumvhcwzvstvtnzrnzknehahdipswtvgmqhmexnjtqcpngvojdxmhwqhrdcgybehvrfsqkroaztrhyeuuzkthfhwtbfnyghlzjqsqjpqvsrkabcxylpgylzzgyzmhruqyezfcvzcmzzuvtxlbfyukhvnytetagrhsebodddqiowahvflakfkefzlwkdjyxtymypkqkeniriybvdcfnqogilpeiviatavcbtxogxenbfhpfqklrekqefzjunpzrenqhorpqnhxllceubkndibdypbmbjscnryafertbursmghissihgmsrubtrefayrncsjbmbpydbidnkbuecllxhnqprohqnerzpnujzfeqkerlkqfphfbnexgoxtbcvataiviepligoqnfcdvbyirinekqkpymytxyjdkwlzfekfkalfvhawoiqdddobeshrgatetynvhkuyfblxtvuzzmczvcfzeyqurhmzygzzlygplyxcbakrsvqpjqsqjzlhgynfbtwhfhtkzuueyhrtzaorkqsfrvhebygcdrhqwhmxdjovgnpcqtjnxemhqmgvtwspidhahenkznrzntvtsvzwchvmuentriivxwecbigzvidctgjfjqhfmdwpeijbelkmnuvpunsodiykf",
             "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg",
             "jglknendplocymmvwtoxvebkekzfdhykknufqdkntnqvgfbahsljkobhbxkvyictzkqjqydczuxjkgecdyhixdttxfqmgksrkyvopwprsgoszftuhawflzjyuyrujrxluhzjvbflxgcovilthvuihzttzithnsqbdxtafxrfrblulsakrahulwthhbjcslceewxfxtavljpimaqqlcbrdgtgjryjytgxljxtravwdlnrrauxplempnbfeusgtqzjtzshwieutxdytlrrqvyemlyzolhbkzhyfyttevqnfvmpqjngcnazmaagwihxrhmcibyfkccyrqwnzlzqeuenhwlzhbxqxerfifzncimwqsfatudjihtumrtjtggzleovihifxufvwqeimbxvzlxwcsknksogsbwwdlwulnetdysvsfkonggeedtshxqkgbhoscjgpiel"]

    for t in tests:
        print(Solution().longestPalindrome(t))
