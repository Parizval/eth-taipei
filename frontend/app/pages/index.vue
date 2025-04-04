<script>
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
        };
    },
    methods: {
        async ConnectWallet() {
            console.log("Wallet Click");
        },
    },
};
</script>

<template>
    <div>
        <UNavigationMenu :items="navbar" class="w-full justify-center" />
        <div class="flex flex-col items-center justify-center gap-4 h-screen">
            <h1 class="font-bold text-2xl text-(--ui-primary)">
                Nuxt UI - Starter
            </h1>

            <div class="flex items-center gap-2">
                <UButton
                    label="Documentation"
                    icon="i-lucide-square-play"
                    to="https://ui.nuxt.com/getting-started/installation/nuxt"
                    target="_blank"
                />

                <UButton
                    label="GitHub"
                    color="neutral"
                    variant="outline"
                    icon="i-simple-icons-github"
                    to="https://github.com/nuxt/ui"
                    target="_blank"
                />
            </div>
        </div>
    </div>
</template>
