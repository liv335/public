class Solution:
    def intToRoman(self, num):
        s = ""
        div = (0,num)
        div_num = [1000,900,500,400,100,90,50,40,10,9,5,4,1]
        r_num = ["M","CM","D","CD","C","XC","L","XL","X","IX","V","IV","I"]
        for d in range(0,len(div_num),1):
            div = divmod(div[1], div_num[d])
            for v in range(div[0]):
                s += r_num[d]
        return s

if __name__ == '__main__':
    test_vals = [1994,3,100,55,777,1249]
    for t in test_vals:
        print("\nresult",Solution().intToRoman(t), "input", t)