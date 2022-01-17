module system
   use const
   
   implicit none

   type system_t
      ! Basic system information
      integer :: nel = 0
      integer :: nbasis = 0
      integer :: natoms = 0
      integer :: nocc = 0
      integer :: nvirt = 0
      integer, allocatable :: charges(:)
      real(p), allocatable :: coords(:,:)

      ! Calculation info
      real(p) :: e_hf = 0.0_p
      real(p) :: e_mp2 = 0.0_p
      real(p) :: e_ccsd = 0.0_p
      real(p) :: e_ccsd_t = 0.0_p

      ! Coefficient matrix of the canonical HF orbitals in the original, nonorthogonal AO basis
      real(p), allocatable :: canon_coeff(:,:)
      real(p), allocatable :: canon_levels(:)
      real(p), allocatable :: canon_levels_spinorb(:)

      ! Converged CCSD amplitudes
      real(p), allocatable :: t1(:,:)
      real(p), allocatable :: t2(:,:,:,:)

      ! Tolerances
      real(p) :: scf_e_tol = 1e-6
      real(p) :: scf_d_tol = 1e-6
      real(p) :: ccsd_e_tol = 1e-6
      real(p) :: ccsd_t_tol = 1e-6

      ! Level of theory (up to)
      character(:), allocatable :: calc_type

   end type system_t

   type state_t
      integer :: iter = 0
      real(p) :: energy = 0.0_p
      real(p) :: energy_old = 0.0_p
      real(p), allocatable :: density_old(:,:)
      real(p), allocatable :: t2_old(:,:,:,:)
   end type state_t

   contains
       subroutine read_system_in(sys)
           ! Reads in input file called `els.in` in `dat/` specifying the levels of theory and tolerance
           ! In/out:
           !    sys: system under study

           use error_handling, only: error
           type(system_t), intent(inout) :: sys
           real(p) :: scf_e_tol, scf_d_tol, ccsd_e_tol, ccsd_t_tol
           character(40) :: calc_type

           integer :: ir, ierr

           ! Define namelist
           namelist /elsinput/ calc_type, scf_e_tol, scf_d_tol, ccsd_e_tol, ccsd_t_tol

           ! Check if file exists
           inquire(file='dat/els.in', iostat=ierr)
           if (ierr /= 0) call error('system::read_system_in', 'input file dat/els.in does not exist')

           ! Read namelist
           open(newunit=ir, file='dat/els.in', action='read')
           read(unit=ir, nml=elsinput, iostat=ierr)

           if (ierr /= 0) call error('system::read_system_in', 'invalid input file format!')

           close(ir)

           sys%calc_type = trim(calc_type); sys%scf_e_tol = scf_e_tol; sys%scf_d_tol = scf_d_tol
           sys%ccsd_e_tol = ccsd_e_tol; sys%ccsd_t_tol = ccsd_t_tol

        end subroutine

end module system
