import Head from "next/head";
import {
  LogInWithCountryIdentity,
  useCountryIdentity,
  CollapsableCode,
} from "country-identity-kit";
import { useEffect } from "react";

export default function Home() {
  const [countryIdentity] = useCountryIdentity();

  useEffect(() => {
    console.log("Country Identity state: ", countryIdentity);
  }, [countryIdentity]);

  return (
    <>
      <Head>
        <title>Country Identity Example</title>
        <meta
          name="description"
          content="A Next.js example app that integrate the Country Identity SDK."
        />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <div className="min-h-screen bg-gray-100 px-4 py-8">
        <main className="flex flex-col items-center gap-8 bg-white rounded-2xl max-w-screen-sm mx-auto h-[16rem] p-8">
          <h1 className="font-bold text-2xl">
            Welcome to Country Identity Example
          </h1>
          <p>Prove your Identity anonymously using your Aadhaar card.</p>

          <LogInWithCountryIdentity />
        </main>
        <div className="flex flex-col items-center gap-4 rounded-2xl max-w-screen-sm mx-auto p-8">
          {countryIdentity?.status === "logged-in" && (
            <>
              <p>✅ Proof is valid</p>
              <p>Got your Aadhaar Identity Proof</p>
              <>Welcome anon!</>
              <CollapsableCode
                code={JSON.stringify(countryIdentity.pcd, null, 2)}
              />
            </>
          )}
        </div>
      </div>
    </>
  );
}
