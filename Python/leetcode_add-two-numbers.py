class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next

class Solution:
    def getVal(self,l):
        val = ""
        while l != None:
            val += str(l.val)
            l = l.next
        return int(val[::-1])

    def toList(self,num):
        arrayN = []
        for x in str(num):
            n = ListNode(int(str(x)), next = None)
            arrayN.append(n)
        for n in range(len(arrayN) -1, 0, -1):
            arrayN[n].next = arrayN[n-1]
        return arrayN[-1]

    def addTwoNumbers(self, l1, l2):
        theValue = self.toList(self.getVal(l1) + self.getVal(l2))
        return theValue

valueList1 = ListNode(val=5,next=ListNode(val=4,next=ListNode(val=3,next=None)))
valueList2 = ListNode(val=5,next=ListNode(val=6,next=ListNode(val=4,next=None)))
print(Solution().addTwoNumbers(l1 = valueList1,l2 = valueList2))
