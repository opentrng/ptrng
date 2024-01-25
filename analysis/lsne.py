import numpy as np

# Regression function based on Least Square Normalized Error as proposed by: B. E. Grantham and M. A. Bailey, "A Least-Squares Normalized Error Regression Algorithm with Application to the Allan Variance Noise Analysis Method," 2006 IEEE/ION Position, Location, And Navigation Symposium, Coronado, CA, USA, 2006, pp. 750-756, doi: 10.1109/PLANS.2006.1650671.
def regression(x, y, a):
	H = np.zeros((np.size(x), np.size(a)))
	for r in range(np.size(x)):
		for c in range (np.size(a)):
			H[r, c] = x[r]**a[c]
	C = np.zeros((np.size(a), 1))
	F = np.zeros((np.size(a), np.size(x)))
	for r in range(np.size(x)):
		for c in range (np.size(a)):
			F[c, r] = x[r]**a[c] / y[r]**2
	C = np.matmul(np.matmul(np.linalg.inv(np.matmul(F, H)), F), y)
	return C
