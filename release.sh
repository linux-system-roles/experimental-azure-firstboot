git archive --prefix=firstboot-$(git rev-parse --verify HEAD)/ -o $(rpmspec -q --qf "%{name}-%{version}" SPECS/azurefirstboot.spec).tar.gz HEAD rootfs/ LICENSE
