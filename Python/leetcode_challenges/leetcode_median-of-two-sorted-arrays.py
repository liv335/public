class Solution:
    def findMedianSortedArrays(self, nums1, nums2):
        concant = sorted(nums1 + nums2)
        pos = int((len(concant) + 1)/2) -1
        if (len(concant) % 2) == 0:
            median = (concant[pos] + concant[pos+1])/2
        else:
            median = concant[pos]
        return float(median)

if __name__ == '__main__':
    array1 = [1,3,5,6,7,8,12,19]
    array2 = [2,5,10,12,17,20]

    (Solution().findMedianSortedArrays(array1,array2))