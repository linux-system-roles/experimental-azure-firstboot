git archive --prefix=experimental-azure-firstboot-$(git rev-parse --verify HEAD)/ -o $(rpmspec -q --srpm --qf "%{name}-%{version}" SPECS/azurefirstboot.spec).tar.gz HEAD rootfs/ LICENSE
