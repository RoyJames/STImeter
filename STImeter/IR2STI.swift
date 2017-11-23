import Foundation
// https://www.prosoundtraining.com/2010/03/17/a-do-it-yourselfers-guide-to-computing-the-speech-transmission-index/

func IR2STI (IR: [Double], sampleRate: Int) -> Double{
    let minLength = Int(1.6 * Double(sampleRate))
    let PaddingLength = IR.count < minLength ? minLength - IR.count : sampleRate / 10 //add 100ms zero padding to the beginning
    var fc, f_low, f_high: [Double]
    fc = [125,250,500,1000,2000,4000,8000]  //center frequency for 7 octave bands
    f_low = Array(repeating:0, count: 7); f_high = Array(repeating:0, count: 7) //low and high cutoff frequency for 7 octave bands
    for i in 0...6{
        f_low[i] = fc[i] / (pow(10,0.15))
        f_high[i] = fc[i] * (pow(10,0.15))
    }
    
    var mf: [Double] = Array(repeating: 0, count: 14) //14 modulation frequencies
    for i in 0...13{
        mf[i] = pow(10,Double(i-2) / Double(10))
    }
    
    var fft = FFT()
    var MTF: [[Double]] = Array(repeating: Array(repeating: 0 , count: 14), count: 7) // 7x14 modulation transfer index matrix for octave bands and modulation frequencies
    var appSNR: [Double] = Array(repeating: 0, count: 7) // apparent signal-noise ratio (not actual SNR)
    let STI_weights: [Double] = [0.13,0.14,0.11,0.12,0.19,0.17,0.14]
    let IRLenth: Int = IR.count + PaddingLength
    let paddedIR: [Double] = Array(repeating: 0, count: PaddingLength) + IR
    for i in 0...6{
        //FFT based band-pass filter
        var P_octave = fft.calculate(padpower2(paddedIR), fps: Double(sampleRate), cutlow: f_low[i], cuthigh: f_high[i])
        //P_octave is now the filtered paddedIR, we square each elem to convert to power envelope
        P_octave = P_octave.map({$0 * $0})
        for j in 0...13{
            // number of whole number cycles to use for each modulation frequency
            let Fm_cycles: Int = Int(mf[j] * Double(P_octave.count) / Double(sampleRate))
            // number of samples to use for each modulation frequency
            let Fm_len: Int = Int (Double(Fm_cycles) * Double(sampleRate) / mf[j])
            var MTF_num: Double = 0
            var MTF_i: Double = 0
            var MTF_den: Double = 0
            let factor: Double = Double.pi * -2 * mf[j]
            for k in 0...(Fm_len-1){
                let phase :Double = factor * Double(k) / Double(sampleRate)
                MTF_num += (cos(phase) * P_octave[k])
                MTF_i += (sin(phase) * P_octave[k])
                MTF_den += P_octave[k]
            }
            MTF[i][j] = sqrt(pow(MTF_num,2) + pow(MTF_i,2)) / MTF_den
            //accumulate apparant SNR
            var currSNR : Double = Double(10) * logCf(val: MTF[i][j],base: 10) / (Double(1) - MTF[i][j])

            // limit value to [-15,15] dB
            currSNR = currSNR < -15 ? -15 : currSNR > 15 ? 15 : currSNR
            appSNR[i] += currSNR
        }
        appSNR[i] /= Double(14)
    }
    let zipped : [Double] = Array(zip(appSNR,STI_weights).map({$0 * $1}))
    let reduced : Double = zipped.reduce(0.0) {$0 + $1}
    return (reduced + Double(15)) / Double(30)
}

func logCf(val : Double, base : Double) -> Double{ //swift does not have a custom logarithmic function in standard libs
    return log(val)/log(base)
}
