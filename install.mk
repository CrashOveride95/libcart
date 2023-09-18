install: default
	$(V)mkdir -p /usr/lib/n64/ /usr/include/n64/
	@$(PRINT) "$(GREEN)Copying libcart.a$(NO_COL)\n"
	$(V)cp $(BUILD_DIR)/libcart.a /usr/lib/n64/libcart.a
	@$(PRINT) "$(GREEN)Copying cart.h$(NO_COL)\n"
	$(V)cp include/cart.h /usr/include/n64/cart.h

# for internal apt use only
pkginstall: default
	$(V)mkdir -p /home/crash/n64dev/n64sdkmod/packages/libcart/usr/lib/n64/ /home/crash/n64dev/n64sdkmod/packages/libcart/usr/include/n64/
	@$(PRINT) "$(GREEN)Copying libcart.a$(NO_COL)\n"
	$(V)cp $(BUILD_DIR)/libcart.a /home/crash/n64dev/n64sdkmod/packages/libcart/usr/lib/n64/libcart.a
	@$(PRINT) "$(GREEN)Copying cart.h$(NO_COL)\n"
	$(V)cp include/cart.h /home/crash/n64dev/n64sdkmod/packages/libcart/usr/include/n64/cart.h
