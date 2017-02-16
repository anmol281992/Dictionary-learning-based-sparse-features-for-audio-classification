% Steven Wong    sw2384

function melval = hz2mel(hzval)
%   Convert a vector of values in Hz to Mels.
%
%   Parameters
%   ----------
%   hzval : 1 x N array
%       values in Hz
%
%   Returns
%   -------
%   melval : 1 x N array
%       values in Mels
%__________________________________________________________________________

% Equation from lecture slides.
melval = 1127.01028 * log(1 + hzval/700);

end