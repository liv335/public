class Solution:
    def checkLength(self, nums):
        if 2 <= len(nums) <= pow(10, 3):
            return True
        else:
            raise Exception("nums list invalid length")

    def checkMinMax(self, nums):
        if (sorted(nums))[0] >= pow(-10, 9) and (sorted(nums))[-1] <= pow(10, 9):
            return True
        else:
            raise Exception("nums list outside of range")

    def checkTarget(self, target):
        if pow(-10,9) <= target <= pow(10,9):
            return True
        else:
            raise Exception("Target outside of range")

    def checkValues(self, nums, target):
        if type(target) == int and all(isinstance(x, (int, nums)) for x in nums):
            return True
        raise Exception("nums array and target must be an integer")

    def twoSum(self, nums , target):
        for n in range(len(nums)):
            for m in range(len(nums)):
                if nums[n] + nums[m] == target and n != m:
                    return [n,m]
        pass

listNumbers = [3,3]
targetValue = 6
theSolution = Solution().twoSum(nums = listNumbers, target = targetValue)
print(theSolution)
