import Foundation
// https://www.prosoundtraining.com/2010/03/17/a-do-it-yourselfers-guide-to-computing-the-speech-transmission-index/

func IR2STI (IR: [Float], sampleRate: Int) -> Float{

    let PaddingLength = sampleRate / 10 //add 100ms zero padding to the beginning
    var fc, f_low, f_high: [Float]
    fc = [125,250,500,1000,2000,4000,8000]  //center frequency for 7 octave bands
    f_low = Array(repeating:0, count: 7); f_high = Array(repeating:0, count: 7) //low and high cutoff frequency for 7 octave bands
    for i in 0...6{
        f_low[i] = fc[i] / (pow(10,0.15))
        f_high[i] = fc[i] * (pow(10,0.15))
    }
    var mf: [Float] = Array(repeating: 0, count: 14) //14 modulation frequencies
    for i in 0...13{
        mf[i] = pow(10,Float(i-2) / Float(10))
    }
    var MTF: [[Float]] = Array(repeating: Array(repeating: 0 , count: 14), count: 7) // 7x14 modulation transfer index matrix for octave bands and modulation frequencies
    var appSNR: [Float] = Array(repeating: 0, count: 7) // apparent signal-noise ratio (not actual SNR)
    let STI_weights: [Float] = [0.13,0.14,0.11,0.12,0.19,0.17,0.14]
    let IRLenth: Int = IR.count + PaddingLength
    let paddedIR: [Float] = Array(repeating: 0, count: PaddingLength) + IR
    for i in 0...6{
        var P_octave: [Float] = Array(repeating: 0, count: paddedIR.count)
        P_octave.append(contentsOf:IR)
        //Construct band-pass filter
        //todo:
        //P_octave is now the filtered paddedIR, we square each elem to convert to power envelope
        P_octave = P_octave.map({$0 * $0})
        for j in 0...13{
            // number of whole number cycles to use for each modulation frequency
            let Fm_cycles: Int = Int(mf[j] * Float(IRLenth) / Float(sampleRate))
            // number of samples to use for each modulation frequency
            let Fm_len: Int = Int (Float(Fm_cycles) * Float(sampleRate) / mf[j])
            var MTF_num: Float = 0
            var MTF_i: Float = 0
            var MTF_den: Float = 0
            let factor: Float = Float.pi * -2 * mf[j]
            for k in 0...(Fm_len-1){
                let phase :Float = factor * Float(k) / Float(sampleRate)
                MTF_num += (cosf(phase) * P_octave[k])
                MTF_i += (sinf(phase) * P_octave[k])
                MTF_den += P_octave[k]
            }
            MTF[i][j] = sqrtf(pow(MTF_num,2) + pow(MTF_i,2)) / MTF_den
            //accumulate apparant SNR
            var currSNR : Float = Float(10) * logCf(val: MTF[i][j],base: 10) / (Float(1) - MTF[i][j])

            // limit value to [-15,15] dB
            currSNR = currSNR < -15 ? -15 : currSNR > 15 ? 15 : currSNR
            appSNR[i] += currSNR
        }
        appSNR[i] /= Float(14)
    }
    let zipped : [Float] = Array(zip(appSNR,STI_weights).map({$0 * $1}))
    let reduced : Float = zipped.reduce(0.0) {$0 + $1}
    return (reduced + Float(15)) / Float(30)

}

func logCf(val : Float, base : Float) -> Float{ //swift does not have a custom logarithmic function in standard libs
    return log(val)/log(base)
}
