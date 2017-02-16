% Steven Wong    sw2384

function hzval = mel2hz(melval)
%   Convert a vector of values in Hz to Mels.
%
%   Parameters
%   ----------
%   melval : 1 x N array
%       values in Mels
%
%   Returns
%   -------
%   hzval : 1 x N array
%       values in Hz
%__________________________________________________________________________

% Equation from lecture slides.
hzval = 700 * (exp(melval/1127.01028) - 1);

end