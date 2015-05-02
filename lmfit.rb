class Lmfit < Formula
  homepage "http://apps.jcns.fz-juelich.de/doku/sc/lmfit"
  url "http://apps.jcns.fz-juelich.de/src/lmfit/old/lmfit-5.1.tgz"
  sha256 "4e35bdec551a4985cf6d96f26a808b56c171433edf4a413c2ed50ab3d85a3965"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS
      #include "lmcurve.h"
      #include "lmmin.h"

      /* model function: a parabola */

      double f_curve( double t, const double *p )
      {
        return p[0] + p[1]*t + p[2]*t*t;
      }

      /* fit model: a plane p0 + p1*tx + p2*tz */
      double f_min( double tx, double tz, const double *p )
      {
          return p[0] + p[1]*tx + p[2]*tz;
      }

      /* data structure to transmit arrays and fit model */
      typedef struct {
          double *tx, *tz;
          double *y;
          double (*f)( double tx, double tz, const double *p );
      } data_struct;

      /* function evaluation, determination of residues */
      void evaluate_surface( const double *par, int m_dat, const void *data,
                             double *fvec, int *info )
      {
          /* for readability, explicit type conversion */
          data_struct *D;
          D = (data_struct*)data;

          int i;
          for ( i = 0; i < m_dat; i++ )
               fvec[i] = D->y[i] - D->f( D->tx[i], D->tz[i], par );
      }

      int main()
      {
        // Evaluate lmcurve
        {
          int n = 3; /* number of parameters in model function f */
          double par[3] = { 100, 0, -10 }; /* really bad starting value */

          /* data points: a slightly distorted standard parabola */
          int m = 9;
          int i;
          double t[9] = { -4., -3., -2., -1.,  0., 1.,  2.,  3.,  4. };
          double y[9] = { 16.6, 9.9, 4.4, 1.1, 0., 1.1, 4.2, 9.3, 16.4 };

          lm_control_struct control = lm_control_double;
          lm_status_struct status;
          control.verbosity = 9;

          /* now the call to lmfit */
          lmcurve( n, par, m, t, y, f_curve, &control, &status );
        }

        {
          //Evaluate lmmin

          /* parameter vector */
          int n_par = 3;                /* number of parameters in model function f */
          double par[3] = { -1, 0, 1 }; /* arbitrary starting value */

          /* data points */
          int m_dat = 4;
          double tx[4] = { -1, -1,  1,  1 };
          double tz[4] = { -1,  1, -1,  1 };
          double y[4]  = {  0,  1,  1,  2 };

          data_struct data = { tx, tz, y, f_min };

          /* auxiliary parameters */
          lm_status_struct status;
          lm_control_struct control = lm_control_double;
          control.verbosity = 9;

          /* perform the fit */
          lmmin( n_par, par, m_dat, (const void*) &data,
                 evaluate_surface, &control, &status );
        }

        return 0;
      }
    EOS

    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-llmfit", "-o", "test"
    system "./test"
  end
end
