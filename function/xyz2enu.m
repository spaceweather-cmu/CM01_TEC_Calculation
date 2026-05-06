function enu = xyz2enu(spos,rpos)
    % spos: satellite position ([x, y, z],time)
    % rpos: receiver position [xr, yr, zr]
    
    % Calculate position vector from reference point to point of interest
    delta_ecef = spos - rpos;
    
    % Define rotation matrix to align ECEF axes with local tangent plane
    phi   = atan2(rpos(2), rpos(1));
    theta = atan2(rpos(3), sqrt(rpos(1)^2 + rpos(2)^2));
    R = [ -sin(phi)            cos(phi)             0;
          -sin(theta)*cos(phi) -sin(theta)*sin(phi) cos(theta);
           cos(theta)*cos(phi)  cos(theta)*sin(phi) sin(theta)];
    
    % Rotate position vector to align with local tangent plane
    enu = R * delta_ecef;
    
end