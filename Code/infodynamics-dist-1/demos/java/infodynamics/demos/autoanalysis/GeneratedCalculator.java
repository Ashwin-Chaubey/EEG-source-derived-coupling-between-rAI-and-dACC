package infodynamics.demos.autoanalysis;

import infodynamics.utils.ArrayFileReader;
import infodynamics.utils.EmpiricalMeasurementDistribution;
import infodynamics.utils.MatrixUtils;

import infodynamics.measures.continuous.*;
import infodynamics.measures.continuous.kraskov.*;

public class GeneratedCalculator {

  public static void main(String[] args) throws Exception {

    // 0. Load/prepare the data:
    String dataFile = "/Users/ashwinchaubey/Documents/MATLAB/eeglab2024-2.0/Participants/stay_upto_n&leave2/stay5/EEG_data_matrix.txt";
    ArrayFileReader afr = new ArrayFileReader(dataFile);
    double[][] data = afr.getDouble2DMatrix();
    double[] source = MatrixUtils.selectColumn(data, 19);
    double[] destination = MatrixUtils.selectColumn(data, 3);

    // 1. Construct the calculator:
    TransferEntropyCalculatorKraskov calc;
    calc = new TransferEntropyCalculatorKraskov();
    // 2. Set any properties to non-default values:
    calc.setProperty(ConditionalMutualInfoCalculatorMultiVariateKraskov.PROP_K,
        "6");
    calc.setProperty(ConditionalMutualInfoCalculatorMultiVariateKraskov.PROP_NORM_TYPE,
        "EUCLIDEAN_SQUARED");
    calc.setProperty(TransferEntropyCalculatorViaCondMutualInfo.PROP_RAGWITZ_NUM_NNS,
        "4");
    // 3. Initialise the calculator for (re-)use:
    calc.initialise();
    // 4. Supply the sample data:
    calc.setObservations(source, destination);
    // 5. Compute the estimate:
    double result = calc.computeAverageLocalOfObservations();
    // 6. Compute the (statistical significance via) null distribution empirically (e.g. with 100 permutations):
    EmpiricalMeasurementDistribution measDist = calc.computeSignificance(100);

    System.out.printf("TE_Kraskov (KSG)(col_19 -> col_3) = %.4f nats (null: %.4f +/- %.4f std dev.; p(surrogate > measured)=%.5f from %d surrogates)\n",
        result, measDist.getMeanOfDistribution(), measDist.getStdOfDistribution(), measDist.pValue, 100);
  }
}

