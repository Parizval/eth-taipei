<script>
import { createWalletClient, custom } from "viem";
import { baseSepolia, avalancheFuji } from "viem/chains";
import { ethers } from "ethers";
import { UiPoolDataProvider, ChainId } from "@aave/contract-helpers";
import * as markets from "@bgd-labs/aave-address-book";
import { formatUserSummary, formatReserves } from "@aave/math-utils";
import dayjs from "dayjs";


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
            ConditionTypeValue : 0,
            ConditionType:[
                { label: "Total Collateral Base Value", value: 0 },
                { label: "Total Debt Base Value", value: 1 },
                { label: "Loan-To-Value Ratio", value: 2 },
                { label: "Total Debt USD Value", value: 3 },
            ],
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

                this.computeAaveData();
                

            } catch (error) {
                console.log(error);
            }
        },
        async computeAaveData(){

            const provider = new ethers.providers.JsonRpcProvider(
                    "https://polygon-mainnet.g.alchemy.com/v2/AAk893PV9j8JfH3lVW-EHguNXMVkk6S-",
                );

                console.log("Provider Connected");

                console.log(
                    `Pool_DATA_Provider: ${markets.AaveV3Polygon.UI_POOL_DATA_PROVIDER}`,
                );

                const poolDataProviderContract = new UiPoolDataProvider({
                    uiPoolDataProviderAddress:
                        markets.AaveV3Polygon.UI_POOL_DATA_PROVIDER,
                    provider,
                    chainId: ChainId.polygon,
                });


                const currentAccount =
                    "0xE451141fCE63EB38e85F08a991fC5878Ee6335b2";

                const reserves =
                    await poolDataProviderContract.getReservesHumanized({
                        lendingPoolAddressProvider:
                            markets.AaveV3Polygon.POOL_ADDRESSES_PROVIDER,
                    });

                    const userReserves =
                    await poolDataProviderContract.getUserReservesHumanized({
                        lendingPoolAddressProvider:
                            markets.AaveV3Polygon.POOL_ADDRESSES_PROVIDER,
                        user: currentAccount,
                    });

                const reservesArray = reserves.reservesData;
                const baseCurrencyData = reserves.baseCurrencyData;
                const userReservesArray = userReserves.userReserves;

                const currentTimestamp = dayjs().unix();

                const formattedReserves = formatReserves({
                    reserves: reservesArray,
                    currentTimestamp,
                    marketReferenceCurrencyDecimals:
                        baseCurrencyData.marketReferenceCurrencyDecimals,
                    marketReferencePriceInUsd:
                        baseCurrencyData.marketReferenceCurrencyPriceInUsd,
                });

                const userSummary = formatUserSummary({
                    currentTimestamp,
                    marketReferencePriceInUsd:
                        baseCurrencyData.marketReferenceCurrencyPriceInUsd,
                    marketReferenceCurrencyDecimals:
                        baseCurrencyData.marketReferenceCurrencyDecimals,
                    userReserves: userReservesArray,
                    formattedReserves,
                    userEmodeCategoryId: userReserves.userEmodeCategoryId,
                });

                console.log(userSummary);


        }


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

            <h2 class="font-bold text-2xl text-(--ui-secondary)">
                Select Loan Condition Type
            </h2>
            <USelect v-model="ConditionTypeValue" :items="ConditionType" class="w-48" />

            <h2 class="font-bold text-2xl text-(--ui-secondary)">
                Select Loan Condition Type
            </h2>
            <USelect v-model="ConditionTypeValue" :items="ConditionType" class="w-48" />

            <h2 class="font-bold text-2xl text-(--ui-secondary)">
                Select Loan Condition Type
            </h2>
            <USelect v-model="ConditionTypeValue" :items="ConditionType" class="w-48" />

            <h2 class="font-bold text-2xl text-(--ui-secondary)">
                Select Loan Condition Type
            </h2>
            <USelect v-model="ConditionTypeValue" :items="ConditionType" class="w-48" />
            <h2 class="font-bold text-2xl text-(--ui-secondary)">
                Select Loan Condition Type
            </h2>
            <USelect v-model="ConditionTypeValue" :items="ConditionType" class="w-48" />

            <h2 class="font-bold text-2xl text-(--ui-secondary)">
                Select Loan Condition Type
            </h2>
            <USelect v-model="ConditionTypeValue" :items="ConditionType" class="w-48" />


            <UButton
                label="Subtmit Order"        
            />

        </div>
        
    </div>
</template>
