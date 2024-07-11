from jpype import *
import numpy
import sys
# Our python data file readers are a bit of a hack, python users will do better on this:
sys.path.append("/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/infodynamics-dist-1/demos/python")
import readFloatsFile

if (not isJVMStarted()):
    # Add JIDT jar library to the path
    jarLocation = "/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/infodynamics-dist-1/infodynamics.jar"
    # Start the JVM (add the "-Xmx" option with say 1024M if you get crashes due to not enough memory space)
    startJVM(getDefaultJVMPath(), "-ea", "-Djava.class.path=" + jarLocation, convertStrings=True)

# 0. Load/prepare the data:
dataRaw = readFloatsFile.readFloatsFile("/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/stay_upto_n&leave2/stay5/EEG_data_matrix.txt")
# As numpy array:
data = numpy.array(dataRaw)
source = JArray(JDouble, 1)(data[:,19].tolist())
destination = JArray(JDouble, 1)(data[:,3].tolist())

# 1. Construct the calculator:
calcClass = JPackage("infodynamics.measures.continuous.kraskov").TransferEntropyCalculatorKraskov
calc = calcClass()
# 2. Set any properties to non-default values:
calc.setProperty("k", "6")
calc.setProperty("NORM_TYPE", "EUCLIDEAN_SQUARED")
calc.setProperty("AUTO_EMBED_RAGWITZ_NUM_NNS", "4")
# 3. Initialise the calculator for (re-)use:
calc.initialise()
# 4. Supply the sample data:
calc.setObservations(source, destination)
# 5. Compute the estimate:
result = calc.computeAverageLocalOfObservations()
# 6. Compute the (statistical significance via) null distribution empirically (e.g. with 100 permutations):
measDist = calc.computeSignificance(100)

print("TE_Kraskov (KSG)(col_19 -> col_3) = %.4f nats (null: %.4f +/- %.4f std dev.; p(surrogate > measured)=%.5f from %d surrogates)" %\
    (result, measDist.getMeanOfDistribution(), measDist.getStdOfDistribution(), measDist.pValue, 100))
