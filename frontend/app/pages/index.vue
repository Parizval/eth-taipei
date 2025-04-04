<script>
import { createWalletClient, custom } from "viem";
import { baseSepolia, avalancheFuji } from "viem/chains";

export default {
    data() {
        return {
            navbar: [
                {
                    label: "GitHub",
                    icon: "i-simple-icons-github",
                    to: "https://github.com/Parizval/eth-taipei",
                    target: "_blank",
                },
            ],
            walletLabel: "Connect Wallet",
            walletClient: {},
            userAddress: "",
        };
    },
    methods: {
        async ConnectWallet() {
            try {
                console.log("Wallet Click");
                this.walletClient = createWalletClient({
                    chain: baseSepolia,
                    transport: custom(window.ethereum),
                });

                this.walletClient.addChain({chain : avalancheFuji});
    
                await this.walletClient.switchChain({ id: baseSepolia.id });

                const [address] = await this.walletClient.getAddresses();
                this.userAddress = address;

                this.walletLabel = "Connected: " + address.slice(0, 5) + "..." + address.slice(-4);


                console.log(`userAddress: ${address}`);
            } catch (error) {
                console.log(error);
            }
        },
    },
};
</script>

<template>
    <div>
        <UNavigationMenu :items="navbar" class="w-full justify-center" />
        <div class="flex flex-col items-center justify-center gap-4 h-screen">
            <h2 class="font-bold text-2xl text-(--ui-primary)">
                Create Limit Order for your Aave Borrow Position
            </h2>

            <div class="flex items-center gap-2">
                <UButton
                    :label="walletLabel"
                    icon="i-lucide-square-play"
                    @click="ConnectWallet"
                />
            </div>
        </div>
    </div>
</template>
