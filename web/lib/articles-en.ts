import type { ArticleSection } from "./article-bodies";

// English versions of every article, same slugs as the Indonesian data (lib/articles.ts).
// Faithful translations of the Indonesian text (including the AI-assisted drafts after the Phase 9b rewrites): nothing is added.
// Titles keep the same truncation as the Indonesian list titles (the full titles are not available).
// `extra` is the additional section that lib/articles.ts inserts before the closing section, as for the Indonesian text.
export type ArticleEn = { title: string; date?: never; excerpt?: string; sections: ArticleSection[]; extra?: ArticleSection; pull?: string };

export const articlesEn: Record<string, ArticleEn> = {
  "mendukung-ketahanan-pangan-melalui-agribisnis-perikanan-air-tawar": {
    title: "Supporting Food Security Through Freshwater Fisheries Agribusiness",
    excerpt: "Freshwater fisheries agribusiness is an increasingly strategic sector in supporting food security in many countries. With...",
    pull: "Food security is not built by a single step.",
    sections: [
      { paragraphs: [
        "Freshwater fish has long been part of many families' tables. Behind the supply that reaches the market, there is a chain of activities that starts at the fish pond and ends in the buyer's hands. Freshwater fisheries agribusiness brings that chain together: from hatchery to grow-out to marketing.",
        "The photo of activity at the edge of a pond in this article shows that a pond can also be a place where residents meet, not just a place of production.",
      ] },
      { heading: "Fish Farming as the Main Pillar:", paragraphs: [
        "Fish farming gives a more planned supply of fish than wild catches. Farmers can set the kind of fish, the stocking time, and the harvest time to fit market demand. A steadier supply helps buyers get fresh fish continuously.",
      ] },
      { heading: "Managing Natural Resources:", paragraphs: [
        "Ponds depend on the quality of water and land. Good management means keeping the water clean, feeding just enough, and avoiding waste that pollutes the surrounding environment. Farmers who look after their environment also look after the continuity of their own business.",
      ] },
      { heading: "Opportunities for Local Economic Development:", paragraphs: [
        "Pond businesses create supporting activities around them, such as suppliers of feed and equipment, transport, and traders. When these activities run at the village or district level, the economic turnover is felt by the local community.",
      ] },
      { heading: "Sustainability of Fisheries Agribusiness:", paragraphs: [
        "For a business to last, farmers need to balance harvests with the health of the environment. Technical knowledge, cooperation among farmers, and clear access to markets are important supports.",
        "Food security is not built by a single step. It grows from small, consistent habits in the pond, at the market, and in the kitchen.",
      ] },
    ],
    extra: {
      heading: "The role of buyers and consumers",
      paragraphs: [
        "The food chain does not involve only producers. Buyers who choose fish from local farmers help keep pond businesses running. Simple habits, such as choosing fresh fish and asking where it comes from, encourage sellers and farmers to maintain quality. At the household level, fish can also help diversify side dishes so that a family's menu does not depend on a single ingredient.",
      ],
    },
  },

  "budidaya-ikan-air-tawar-menggunakan": {
    title: "Freshwater Fish Farming Using....",
    excerpt: "A paddlewheel in the middle of the pond helps keep the water quality good for the fish being raised.",
    sections: [
      { paragraphs: [
        "On many fish farms, simple equipment often plays a big role. In the photo for this article you can see a paddlewheel turning in the middle of a pond, splashing water into the air. Equipment like this is commonly used by farmers to help maintain water conditions.",
      ] },
      { heading: "Why water needs to move", paragraphs: [
        "Fish take in the oxygen dissolved in the water. Still water, especially in a crowded pond, can run short of oxygen. Moving water helps oxygen from the air dissolve into the pond and helps spread oxygen more evenly.",
      ] },
      { heading: "The paddlewheel's role in daily work", paragraphs: [
        "A paddlewheel is usually driven by a motor and timed by the farmer. Experienced farmers watch for signs in the fish, such as fish often coming up to the surface, as a hint that the water conditions need to be improved.",
      ] },
      { heading: "Basic care that still matters", paragraphs: [
        "Equipment does not replace basic care. Excess feed sinks and worsens the water quality. That is why feeding just enough, checking the water regularly, and keeping the pond clean remain key.",
        "The paddlewheel also needs maintenance to work well, for example checking the rotating parts and the electrical connections so they are safe to use.",
      ] },
      { heading: "Closing", paragraphs: [
        "Freshwater fish farming is a combination of observation, care, and the right equipment. Simple equipment used correctly can help maintain pond conditions and the harvest.",
      ] },
    ],
    extra: {
      heading: "Watching the pond every day",
      paragraphs: [
        "The habit of watching the pond in the morning and evening helps farmers notice changes early. The color of the water, the fish's appetite, and the fish's behavior at the surface are simple clues. If something looks unusual, farmers can quickly check the water, reduce feed, or adjust how the equipment runs. Daily notes, even short ones, make it easier for farmers to compare pond conditions over time and make calmer decisions.",
      ],
    },
  },

  "memahami-ciri-ciri-perikanan-air-tawar": {
    title: "Understanding the Characteristics of Freshwater....",
    excerpt: "Freshwater fisheries take place in rivers, lakes, and ponds. Knowing their characteristics helps us understand how fish live and are managed.",
    sections: [
      { paragraphs: [
        "Freshwater fisheries cover catching and farming fish that live in water with very low salt content, such as rivers, lakes, reservoirs, and ponds. The photo in this article shows a fish swimming among clear aquatic plants.",
      ] },
      { heading: "Diverse habitats", paragraphs: [
        "Fresh water can be a cold, fast-flowing stream or a calm, warm pond. Each kind of fish adapts to its conditions, so not every fish suits every place.",
      ] },
      { heading: "Aquatic plants as part of the ecosystem", paragraphs: [
        "Aquatic plants provide shelter, places to lay eggs, and food for small organisms that become natural feed. Their presence is often a sign that the water is still in reasonably good condition.",
      ] },
      { heading: "Two ways to get fish", paragraphs: [
        "Freshwater fish can be obtained from catching in public waters or from farming in ponds or cages. Farming gives more control over the kind of fish and the time of harvest, while catching depends heavily on natural conditions and the health of the waters.",
      ] },
      { heading: "Closing", paragraphs: [
        "Understanding the characteristics of freshwater fisheries helps us appreciate where the fish we eat comes from. Well-kept waters are the main asset, both for fish in the wild and for fish farming.",
      ] },
    ],
    extra: {
      heading: "Why these characteristics matter to farmers",
      paragraphs: [
        "Farmers who understand the characteristics of fresh water can recreate the conditions fish like in their ponds. Clear water, available oxygen, and a temperature that is not too hot or too cold make fish more comfortable. This knowledge also helps farmers choose fish that suit the water source nearby, so they do not have to force a kind of fish that needs different conditions and risks failure.",
      ],
    },
  },

  "5-manfaat-ikan-air-tawar": {
    title: "These 5 Benefits of Freshwater Fish for....",
    excerpt: "Freshwater fish can be part of a varied daily menu. Here is a general picture of the benefits that are often mentioned.",
    sections: [
      { paragraphs: [
        "Freshwater fish is easy to find at the market and is often a choice for everyday meals. The photo in this article shows fresh fish arranged in a cooler box, a common way to keep fish fresh until it reaches the buyer.",
      ] },
      { heading: "A source of animal protein", paragraphs: [
        "Fish is generally known as a source of animal protein. The body needs protein to build and repair tissue. Adding fish to the menu can enrich the choice of side dishes besides meat and eggs.",
      ] },
      { heading: "A flexible menu", paragraphs: [
        "Freshwater fish can be cooked in many ways, for example fried, grilled, steamed in banana leaf, or served in broth. This variety helps families avoid a boring menu.",
      ] },
      { heading: "Easy to find", paragraphs: [
        "Because it is farmed in many regions, freshwater fish is relatively easy to find, both in traditional markets and in other places that sell it. Buying from local farmers also helps the local economy keep turning around us.",
      ] },
      { heading: "Choosing and preparing it well", paragraphs: [
        "The benefits of fish are felt more when it is chosen and prepared properly. Choose fish that looks fresh, keep it cold, and cook it until done. For special nutritional needs, it is best to consult a health professional.",
      ] },
    ],
    extra: {
      heading: "Support for local farmers",
      paragraphs: [
        "The benefits of fish do not stop at the dinner table. Every purchase of fish from a local farmer helps move the small businesses around us. Farmers get the certainty of buyers, while buyers get fish that comes from closer to where it was raised. A close relationship between seller and buyer also makes it easier for buyers to ask how to choose, store, and cook fish properly.",
      ],
    },
  },

  "5-jenis-ikan-air-tawar": {
    title: "5 Types of Freshwater Fish That Are Often....",
    excerpt: "Several kinds of freshwater fish are often found at markets and fish farms. Learn their general features to make choosing easier.",
    sections: [
      { paragraphs: [
        "Indonesia has a wide variety of freshwater fish that are farmed and eaten. Knowing the kinds helps buyers choose to suit their taste and cooking needs, and helps farmers decide which kind suits their pond.",
      ] },
      { heading: "Catfish (lele)", paragraphs: [
        "Catfish is known to be easy to raise and is widely farmed in ponds, including tarpaulin ponds. Its meat is often fried or grilled.",
      ] },
      { heading: "Nile tilapia (nila) and Mozambique tilapia (mujair)", paragraphs: [
        "Nila and mujair are familiar fish in many families' kitchens. Both are often grilled, fried, or cooked in broth.",
      ] },
      { heading: "Common carp (ikan mas)", paragraphs: [
        "Common carp is farmed in ponds, rice fields, and cages, and is also a well-liked dish in many regions.",
      ] },
      { heading: "Pangasius (patin) and gourami (gurami)", paragraphs: [
        "Pangasius and gourami are also widely farmed and often seen on restaurant menus and as family dishes.",
      ] },
      { heading: "Choosing fresh fish", paragraphs: [
        "Whatever the kind, fresh fish generally has clear eyes, firm flesh, and no strong smell. Keeping it somewhere cold helps preserve freshness until it is time to cook.",
      ] },
    ],
    extra: {
      heading: "Matching the kind to your needs",
      paragraphs: [
        "The kind of fish is best chosen to match its purpose. For everyday side dishes, buyers can choose a kind whose meat suits the way they like to cook. For farmers, the choice of kind is influenced by pond size, water source, and the nearby market. Talking with local farmers or sellers can help you find out which kinds are available and suitable.",
      ],
    },
  },

  "5-fakta-ikan-mujair": {
    title: "Here Are 5 Facts About Mujair....",
    excerpt: "Mujair is a freshwater fish familiar in many kitchens. Here is a general picture of this fish.",
    sections: [
      { paragraphs: [
        "Mujair is one of the freshwater fish people have known for a long time. It is easy to find at the market and is often an everyday side dish. This article sums up a general picture of the fish.",
      ] },
      { heading: "Adapts easily", paragraphs: [
        "Mujair is known to adapt fairly easily to different freshwater conditions. This trait means it is raised in many ponds and waters near settlements.",
      ] },
      { heading: "An omnivorous eater", paragraphs: [
        "In the wild, mujair eats many kinds of food, including aquatic plants and small organisms. In farming, farmers give suitable feed so the fish grow well.",
      ] },
      { heading: "A close relative of nila", paragraphs: [
        "Mujair is often mentioned together with nila because the two are close relatives and have similar bodies. Buyers sometimes find them hard to tell apart, and sellers can usually help explain.",
      ] },
      { heading: "Easy to prepare", paragraphs: [
        "Mujair meat suits many ways of cooking, such as frying, grilling, or cooking in a yellow spice sauce. Choosing fresh fish and cooking it until done is the key to a tasty dish.",
      ] },
    ],
    extra: {
      heading: "Tips for choosing mujair at the market",
      paragraphs: [
        "When buying mujair, look at the appearance of the body. Fresh fish generally looks clean, has clear eyes, and bright gills. Press the body gently; the flesh should feel firm. If you buy in large amounts, keep the fish somewhere cold and cook it as soon as possible to keep it fresh. Sellers are usually willing to clean the fish as the buyer asks.",
      ],
    },
  },

  "ikan-air-tawar-terancam": {
    title: "Freshwater fish around the world are threatened....",
    excerpt: "Rivers, lakes, and swamps are home to many fish. Pressure on fresh water can affect the fish that live in it.",
    sections: [
      { paragraphs: [
        "Fresh waters such as rivers, lakes, and swamps are home to many kinds of fish. The photo in this article shows an angler holding a fish in open water, a reminder that people live close to this resource.",
        "Many pressures can affect the survival of freshwater fish, and many of them come from human activity.",
      ] },
      { heading: "Habitat change and damage", paragraphs: [
        "Building along riverbanks, draining swamps, or changing water flow can change the places where fish feed and breed. When habitat changes, not every fish is able to adapt.",
      ] },
      { heading: "Pollution", paragraphs: [
        "Household waste and other activities that enter the water can affect water quality. Polluted water disturbs fish and other organisms that are part of the food chain.",
      ] },
      { heading: "Uncontrolled fishing", paragraphs: [
        "Overfishing makes it hard for fish populations to recover. That is why local rules and the habit of catching only what is needed are part of looking after the waters.",
      ] },
      { heading: "The role of farming and shared awareness", paragraphs: [
        "Well-managed farming can reduce dependence on wild catches. Even so, keeping the waters clean remains a shared responsibility, from households to businesses.",
      ] },
    ],
    extra: {
      heading: "What can be done",
      paragraphs: [
        "Efforts to look after waters start close to home. Putting trash where it belongs, not dumping waste in rivers, and keeping the water's edge green help protect fish habitat. For anglers, releasing small fish back can help keep the population healthy. Communities and businesses can also work together to keep the quality of the water flow.",
      ],
    },
  },

  "ikan-laut-atau-air-tawar": {
    title: "Which Is More Nutritious: Sea Fish or....",
    excerpt: "Sea fish and freshwater fish can both be a choice for the menu. What matters most is the kind, the freshness, and how it is prepared.",
    pull: "For most people, eating fish in variety is more beneficial than sticking to a single choice.",
    sections: [
      { paragraphs: [
        "The question of which is better, sea fish or freshwater fish, often comes up when people choose a side dish. The photo in this article shows a variety of fish sold at the market, a reminder that the choices out there are very many.",
      ] },
      { heading: "The kind of fish matters more than where it comes from", paragraphs: [
        "Each kind of fish has its own character, in taste, texture, and nutritional content. That is why where a fish comes from is not enough on its own to conclude which group is better.",
      ] },
      { heading: "Freshness and handling", paragraphs: [
        "Fish that is fresh and well handled matters more to the quality of the dish. Fish needs to be kept cold and not left too long at room temperature.",
      ] },
      { heading: "How to cook it", paragraphs: [
        "The way of cooking affects the final dish. Steaming, baking, or boiling generally feels lighter than frying in a lot of oil.",
      ] },
      { heading: "Closing", paragraphs: [
        "For most people, eating fish in variety is more beneficial than sticking to a single choice. For specific nutritional needs, a health professional is the right reference.",
      ] },
    ],
    extra: {
      heading: "Recognizing fresh fish",
      paragraphs: [
        "Whether sea fish or freshwater fish, the signs of freshness are similar. The eyes look clear, the gills are bright, the flesh feels firm, and the smell is not sharp. Fish sold on ice or in a cooler box is generally better preserved. When buying, there is no harm in asking when the fish arrived and how it has been stored, because sellers are usually open to explaining.",
      ],
    },
  },

  "ikan-lele-jenis-air-tawar": {
    title: "Catfish, a Type of Freshwater Fish That Is Popular....",
    excerpt: "Catfish is a freshwater fish that is popular in kitchens and on fish farms.",
    sections: [
      { paragraphs: [
        "Catfish is a freshwater fish well known in Indonesia. The photo in this article shows a group of catfish with their characteristic whiskers. Its popularity shows in the many food stalls and restaurants that make it a main dish.",
      ] },
      { heading: "General features", paragraphs: [
        "Catfish has a long body with smooth skin and barbels around the mouth. These barbels help the fish find food in murky or dark water.",
      ] },
      { heading: "Suited to many scales of business", paragraphs: [
        "Catfish can be raised in earthen ponds, concrete ponds, or tarpaulin ponds. This flexibility lets many people start farming on a small scale in their yard, and then grow if the business goes well.",
      ] },
      { heading: "A familiar market", paragraphs: [
        "Catfish is already familiar to people's tastes, so farmers can relatively easily find buyers nearby, from households to food businesses.",
      ] },
      { heading: "Handling after harvest", paragraphs: [
        "Like other fish, catfish needs to be handled well after harvest so it stays fresh when it reaches the buyer. Clean containers, enough water, and a short delivery time help preserve its quality.",
      ] },
    ],
    extra: {
      heading: "Feed and pond cleanliness",
      paragraphs: [
        "Catfish eats many kinds of food, but feeding still needs to be kept from going overboard. Uneaten feed can make the water dirty quickly. Farmers usually change part of the water regularly and clean the pond to keep the fish in good condition. Simple notes on the feeding schedule and water changes help farmers keep the pond under control.",
      ],
    },
  },

  "perbedaan-perikanan-air-payau": {
    title: "Differences in Brackish Water Fisheries....",
    excerpt: "Brackish water and fresh water have different characters, and both call for different ways of management.",
    sections: [
      { paragraphs: [
        "In fisheries, the type of water decides which fish can be raised and how the pond is managed. Two types that are often compared are brackish water and fresh water.",
      ] },
      { heading: "The basic difference", paragraphs: [
        "Fresh water has very low salt content, as in rivers, lakes, and most ponds. Brackish water is a mix of fresh water and sea water, usually found at river mouths or near the coast.",
      ] },
      { heading: "The fish that are raised", paragraphs: [
        "Not every fish can live in both kinds of water. Each kind of fish has adapted to a certain salt level. That is why farmers choose kinds of fish that suit the water source available.",
      ] },
      { heading: "Managing the pond", paragraphs: [
        "In freshwater fisheries, farmers pay attention to water cleanliness and enough oxygen. In brackish water, changes in salt level caused by rain or tides also need to be watched.",
      ] },
      { heading: "Closing", paragraphs: [
        "Knowing the difference between the two kinds of water helps farmers make the right decisions. Choosing fish that fit their environment is the first step toward successful farming.",
      ] },
    ],
    extra: {
      heading: "Examples of activities in each kind of water",
      paragraphs: [
        "In fresh water, farming is mostly done in ponds, cages, or rice fields. In brackish water, farming is generally done in coastal ponds near the shore or river mouth. The location decides the facilities needed, for example managing water gates and monitoring the salt level. Farmers who move from one type of water to another need to learn these new requirements before they start.",
      ],
    },
  },

  "inovasi-teknologi-budidaya": {
    title: "Technology Innovation in Fish Farming....",
    excerpt: "From tarpaulin ponds to supporting equipment, simple technology can help fish farming run more neatly.",
    sections: [
      { paragraphs: [
        "Fish farming keeps developing as new methods and equipment arrive. The photo in this article shows a row of neatly arranged tarpaulin-lined ponds, with trees and open sky in the background.",
      ] },
      { heading: "Ponds that are easier to manage", paragraphs: [
        "Ponds lined with tarpaulin or synthetic material can be built on land that is not ideal for earthen ponds. Their flat surface makes the ponds easier to clean and monitor.",
      ] },
      { heading: "Supporting water quality", paragraphs: [
        "Oxygen-adding equipment such as paddlewheels or aerators helps maintain water conditions. Farmers also use simple tools to check the clarity and condition of the water regularly.",
      ] },
      { heading: "Record keeping and planning", paragraphs: [
        "Technology does not always mean machines. Recording the stocking, feeding, and harvest schedules helps farmers plan their business and spot problems early.",
      ] },
      { heading: "Closing", paragraphs: [
        "Innovation is useful when it fits farmers' needs and abilities. Technology that is simple, well maintained, and used correctly often brings real benefits.",
      ] },
    ],
    extra: {
      heading: "Learning from fellow farmers",
      paragraphs: [
        "Many innovations come from farmers' own experience. Ways of laying out ponds, setting feeding schedules, or working around limited land are often shared at group meetings. Exchanging experience helps new farmers avoid the same mistakes and helps experienced farmers find more efficient ways. Technology is easier to accept when it is tried together and the results can be seen directly in a neighbor's pond.",
      ],
    },
  },

  "purwakarta-perkuat-posisi": {
    title: "Purwakarta Strengthens Its Position as a....",
    excerpt: "A farming hub grows from ponds, farmers, and marketing channels that support one another.",
    sections: [
      { paragraphs: [
        "A region can become known as a fisheries hub when many farmers work there and the harvest flows to wider markets. The photo in this article shows blue and orange tarpaulin ponds, with workers busy around them.",
      ] },
      { heading: "Farmers as the foundation", paragraphs: [
        "Farmers' skills, passed down and shared among residents, are an important asset. Experience in choosing seed, managing feed, and looking after the water makes harvests more stable.",
      ] },
      { heading: "Support from facilities", paragraphs: [
        "Having water sources, feed, and equipment nearby makes the farmers' work easier. Good transport routes also help fish reach buyers fresh.",
      ] },
      { heading: "Access to markets", paragraphs: [
        "A harvest only gains value when it reaches the buyer. Farmers with clear marketing channels can plan their production with more peace of mind.",
      ] },
      { heading: "Closing", paragraphs: [
        "A region's position in fisheries is built from the shared work of farmers, businesses, and the community. The better the collaboration, the stronger the benefit to the local economy.",
      ] },
    ],
    extra: {
      heading: "Maintaining quality and sustainability",
      paragraphs: [
        "A region that wants to be known as a fisheries hub needs to maintain the quality of its output. Handling fish after harvest, keeping containers clean, and delivering on time affect buyers' trust. At the same time, good management of water and waste lets farming continue in the same place over the long term without harming the surrounding environment.",
      ],
    },
  },

  "pokdakan-dan-poklahsar": {
    title: "Pokdakan and Poklahsar Can Get....",
    excerpt: "Groups of fish farmers and groups of fish processors and marketers are a vehicle for working together in the fisheries sector.",
    sections: [
      { paragraphs: [
        "In the fisheries sector, working together is often done through groups. Two terms that come up often are Pokdakan and Poklahsar. The photo in this article shows a busy fish market, where farmed and caught fish meet buyers.",
      ] },
      { heading: "Pokdakan", paragraphs: [
        "Pokdakan is short for a group of fish farmers. Its members are residents who raise fish and choose to work together to share knowledge, equipment, and experience.",
      ] },
      { heading: "Poklahsar", paragraphs: [
        "Poklahsar is short for a group of fishery product processors and marketers. This group focuses on processing fish into products and marketing them to buyers.",
      ] },
      { heading: "Benefits of working in a group", paragraphs: [
        "Working in a group makes it easier for members to exchange experience, buy supplies together, and set production schedules. A group also makes it easier for members to connect with others who want to cooperate.",
      ] },
      { heading: "Closing", paragraphs: [
        "A group is more than an administrative container. When its members are active and trust one another, a group can become a force that helps small-scale fisheries businesses survive and grow.",
      ] },
    ],
    extra: {
      heading: "Examples of group activities",
      paragraphs: [
        "Group activities can include regular meetings to discuss pond problems, buying farming supplies together, and simple training on processing fish. A processing group can try making products from fish so the harvest has more varied marketing options. These activities depend on the members' willingness to share and to keep one another's trust.",
      ],
    },
  },
};
