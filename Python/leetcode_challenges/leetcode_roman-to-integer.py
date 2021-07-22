class Solution:
    def romanToInt(self, s):
        # good atempt, will optimize
        """
        num = 0
        prev_index = 0
        div_index = 0
        reverse = s[::-1]

        div_num = [1000,900,500,400,100,90,50,40,10,9,5,4,1]
        r_num = ["M","CM","D","CD","C","XC","L","XL","X","IX","V","IV","I"]

        for d in range(0,len(s),1):
            div_index = (div_num[r_num.index(reverse[d])])
            if div_index < prev_index:
                num -= div_index
            else:
                num += div_index
            prev_index = (div_num[r_num.index(reverse[d])])
        return num
        """
        # optimized, faster, cleaner
        #"""
        num = 0
        prev_index = 0

        div_num = [1000,500,100,50,10,5,1]
        r_num = ["M","D","C","L","X","V","I"]

        for d in range(len(s)-1,-1,-1):
            div_index = (div_num[r_num.index(s[d])])
            if div_index < prev_index:
                num -= div_index
            else:
                num += div_index
            prev_index = div_index
        return num
        #"""

if __name__ == '__main__':
    #test_vals = [1994,3,100,55,777,1249]
    test_vals = ["MCMXCIV","III","C","LV","DCCLXXVII","MCCXLIX","MMMCCIII"]
    for t in test_vals:
        print("\nresult",Solution().romanToInt(t), "input", t,"\n")