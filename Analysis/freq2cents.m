function [cents] = freq2cents(freq)
%FREQ2CENTS This function converts the input freq interval expressed in 
% Hz to the value in cents using formula: c = 1200*(ln(fi)/ln(2))
%
%freq(Input): Frequency intervals divided (f1/f2)
%cents(Output): Interval expressed in Cents

cents = 1200*(log(freq)/log(2));

end

