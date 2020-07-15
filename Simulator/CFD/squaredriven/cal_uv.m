function [uout,vout] = cal_uv(u,v)
  include_flags;

  omg = zeros(Nx+1,Ny+1);
  psf = zeros(Nx+1,Ny+1);
  err_uMag = err_uMag_thre + 1;
  nIter = 0;
  while err_uMag > err_uMag_thre && nIter < nIter_max
    nIter = nIter + 1;
    u0 = u; v0 = v;
    
%% Step 1-1: time-marching: calculate vorticity at boundary
    if ind_ps2omg == 1
      omg(2:Nx,1)    = 1/dy/dy * 2 * psf(2:Nx,2);
      omg(2:Nx,Ny+1) = 1/dy/dy * 2 * (psf(2:Nx,Ny) + uMag*dy);
      omg(1,2:Ny)    = 1/dx/dx * 2 * psf(2,2:Ny);
      omg(Nx+1,2:Ny) = 1/dx/dx * 2 * psf(Nx,2:Ny);
    elseif ind_ps2omg == 2
      omg(2:Nx,1)    = 1/dy/dy*(4*psf(2:Nx,2) - 0.5*psf(2:Nx,3));
      omg(2:Nx,Ny+1) = 1/dy/dy*(4*psf(2:Nx,Ny) - 0.5*psf(2:Nx,Ny-1) + 3*uMag*dy);
      omg(1,2:Ny)    = 1/dx/dx*(4*psf(2,2:Ny) - 0.5*psf(3,2:Ny));
      omg(Nx+1,2:Ny) = 1/dx/dx*(4*psf(Nx,2:Ny) - 0.5*psf(Nx-1,2:Ny));
    end
    omg(1,1)       = (omg(1,2) + omg(2,1))/2;
    omg(1,Ny+1)    = (omg(1,Ny) + omg(2,Ny+1))/2;
    omg(Nx+1,Ny+1) = (omg(Nx,Ny+1) + omg(Nx+1,Ny))/2;
    omg(Nx+1,1)    = (omg(Nx,1) + omg(Nx+1,2))/2;

%% Step 1-2: time-marching: calculate vorticity inside the body
    omg0 = omg;
    if ind_uv2omg == 1      % FTCS scheme
      omg(2:Nx,2:Ny) = omg0(2:Nx,2:Ny) ...
        - u(2:Nx,2:Ny) .* (omg0(3:Nx+1,2:Ny) - omg0(1:Nx-1,2:Ny)) * dt/2/dx ...
        - v(2:Nx,2:Ny) .* (omg0(2:Nx,3:Ny+1) - omg0(2:Nx,1:Ny-1)) * dt/2/dy ...
        + 1/Re * dt/dx/dx * (omg0(3:Nx+1,2:Ny) - 2*omg0(2:Nx,2:Ny) + omg0(1:Nx-1,2:Ny)) ...
        + 1/Re * dt/dy/dy * (omg0(2:Nx,3:Ny+1) - 2*omg0(2:Nx,2:Ny) + omg0(2:Nx,1:Ny-1));
    elseif ind_uv2omg == 2     % 1-order upwind scheme
      c_up = 0.5*(u + abs(u))*dt/dx;
      c_un = 0.5*(u - abs(u))*dt/dx;
      c_vp = 0.5*(v + abs(v))*dt/dy;
      c_vn = 0.5*(v - abs(v))*dt/dy;
      omg(2:Nx,2:Ny) = omg0(2:Nx,2:Ny) ...
        - c_up(2:Nx,2:Ny) .* (omg0(2:Nx,2:Ny) - omg0(1:Nx-1,2:Ny)) ...
        - c_un(2:Nx,2:Ny) .* (omg0(3:Nx+1,2:Ny) - omg0(2:Nx,2:Ny)) ...
        - c_vp(2:Nx,2:Ny) .* (omg0(2:Nx,2:Ny) - omg0(2:Nx,1:Ny-1)) ...
        - c_vn(2:Nx,2:Ny) .* (omg0(2:Nx,3:Ny+1) - omg0(2:Nx,2:Ny)) ...
        + 1/Re * dt/dx/dx * (omg0(3:Nx+1,2:Ny) - 2*omg0(2:Nx,2:Ny) + omg0(1:Nx-1,2:Ny)) ...
        + 1/Re * dt/dy/dy * (omg0(2:Nx,3:Ny+1) - 2*omg0(2:Nx,2:Ny) + omg0(2:Nx,1:Ny-1));
    elseif ind_uv2omg == 3     % 2-order upwind scheme
      c_up = 0.5*(u + abs(u))*dt/dx;
      c_un = 0.5*(u - abs(u))*dt/dx;
      c_vp = 0.5*(v + abs(v))*dt/dy;
      c_vn = 0.5*(v - abs(v))*dt/dy;
      % deal with points near the boundary
      ind_omega_i = [2 2 Nx Nx 2*ones(1,Ny-3) Nx*ones(1,Ny-3) 3:(Nx-1) 3:(Nx-1)];
      ind_omega_j = [2 Ny 2 Ny 3:(Ny-1) 3:(Ny-1) 2*ones(1,Nx-3) Ny*ones(1,Nx-3)];
      ind_omega_len = length(ind_omega_i);
      for i = 1:ind_omega_len
        ii = ind_omega_i(i);
        jj = ind_omega_j(i);
        omg(ii,jj) = omg0(ii,jj) ...
          - c_up(ii,jj) * (omg0(ii,jj) - omg0(ii-1,jj)) ...
          - c_un(ii,jj) * (omg0(ii+1,jj) - omg0(ii,jj)) ...
          - c_vp(ii,jj) * (omg0(ii,jj) - omg0(ii,jj-1)) ...
          - c_vn(ii,jj) * (omg0(ii,jj+1) - omg0(ii,jj)) ...
          + 1/Re * dt/dx/dx * (omg0(ii+1,jj) - 2*omg0(ii,jj) + omg0(ii-1,jj)) ...
          + 1/Re * dt/dy/dy * (omg0(ii,jj+1) - 2*omg0(ii,jj) + omg0(ii,jj-1));
      end
      % deal with the real internal points
      omg(inx,iny) = omg0(inx,iny) ...
        - c_up(inx,iny).*(1.5*omg0(inx,iny)-2*omg0(inx-1,iny)+0.5*omg0(inx-2,iny)) ...
        - c_un(inx,iny).*(-0.5*omg0(inx+2,iny)+2*omg0(inx+1,iny)-1.5*omg0(inx,iny)) ...
        - c_vp(inx,iny).*(1.5*omg0(inx,iny)-2*omg0(inx,iny-1)+0.5*omg0(inx,iny-2)) ...
        - c_vn(inx,iny).*(-0.5*omg0(inx,iny+2)+2*omg0(inx,iny+1)-1.5*omg0(inx,iny)) ...
        + 1/Re * dt/dx/dx * (omg0(inx+1,iny) - 2*omg0(inx,iny) + omg0(inx-1,iny)) ...
        + 1/Re * dt/dy/dy * (omg0(inx,iny+1) - 2*omg0(inx,iny) + omg0(inx,iny-1));
    end

%% Step 2: inner-iteration: calculation of psf
    if ind_psifun == 1   % Gauss-Seidel scheme
      err_psf = err_psf_thre + 1;
      while err_psf > err_psf_thre
        psf0 = psf;
        psf(2:Nx,2:Ny) = ((psf(3:Nx+1,2:Ny) + psf(1:Nx-1,2:Ny))/dx/dx ...
                        + (psf(2:Nx,3:Ny+1) + psf(2:Nx,1:Ny-1))/dy/dy ...
                        - omg(2:Nx,2:Ny)) / (2*(1/dx/dx + 1/dy/dy));
        err_psf = max(max(abs(psf - psf0)));
      end
    end

%% Step 3: update the flow field (u,v)
    if ind_ps2uv == 1
      u(2:Nx,2:Ny) = (psf(2:Nx,3:Ny+1) - psf(2:Nx,1:Ny-1))/2/dy;
      v(2:Nx,2:Ny) = (psf(1:Nx-1,2:Ny) - psf(3:Nx+1,2:Ny))/2/dx;
    elseif ind_ps2uv == 2
      u(2:Nx,2) = (psf(2:Nx,3) - psf(2:Nx,1))/2/dy;
      u(2:Nx,3:Ny) = (2*psf(2:Nx,4:Ny+1) + 3*psf(2:Nx,3:Ny) - 6*psf(2:Nx,2:Ny-1) + psf(2:Nx,1:Ny-2))/6/dy;
      v(2,2:Ny) = -(psf(3,2:Ny) - psf(1,2:Ny))/2/dx;
      v(3:Nx,2:Ny) = -(2*psf(4:Nx+1,2:Ny) + 3*psf(3:Nx,2:Ny) - 6*psf(2:Nx-1,2:Ny) + psf(1:Nx-2,2:Ny))/6/dx;
    end
  
    err_uMag = max(max(max(abs(u - u0))),max(max(abs(v - v0))));
    if (mod(nIter,outputInt) == 0)
      fprintf('%s%i%s%e\n','The ',nIter,'th step gets accuracy = ',err_uMag);
    end
  end
  uout = u;
  vout = v;
end
