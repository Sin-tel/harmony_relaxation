# harmony_relaxation
just intonation harmony exploration

made with love2d. to run this:
- install love2d from https://love2d.org/  (you need 11.x)
- download the files 
- zip them (make sure main.lua is at top and not inside another folder)
- rename .zip to .love

guide:
 - the system will try to find a local optimum of least dissonance
 - red lines are playing notes, yellow and blue lines are harmonics and subharmonics respectively (used as guides)
 - click and drag to change notes
 - scroll to change temperature. higher temperatures mean the system will 'explore' more
 - the triangle of numbers are the cents distances between all the notes
   first column is first neighbors, second column is skipping one etc
 
 how it works:
  - 4 octave function of harmonic entropy is calculated, see https://en.xen.wiki/w/Harmonic_Entropy
    (i use a standard deviation of 10 cents, and weighting with sqrt(n*d))
    this gives a relative dissonance of dyads
  - the total potential is a (weighted) sum of all the dyad potentials
  - the system tries to minimise this by randomly moving some notes. then if the potential is lower the move is accepted. 
    if the new potential is higher it is only based on a Boltzmann factor. (ie probability of acceptance =  exp(  -(p_new - p_old)/T) ) 
    this is analogous to simulated annealing.
