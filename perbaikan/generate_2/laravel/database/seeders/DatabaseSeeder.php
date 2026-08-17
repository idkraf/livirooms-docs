<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            // Base
            UserSeeder::class,
            CitySeeder::class,

            // Properties & Hotels
            PropertySeeder::class,
            HotelSeeder::class,

            // Polymorphic core
            FacilitySeeder::class,
            PropertyMediaSeeder::class,
            PropertyFacilitySeeder::class,

            // Property module
            PropertyPricingOptionSeeder::class,
            PropertySpecialPriceSeeder::class,
            PropertyAddOnSeeder::class,
            PropertyPaymentPlanSeeder::class,
            PropertyPromoSeeder::class,
            PropertyOtherCoreSeeder::class,
            PropertyExtraDescriptionSeeder::class,
            PropertyReviewSummarySeeder::class,
            PropertyReviewBreakdownSeeder::class,
            PropertySpecSeeder::class,
            PropertyBedFacilitySeeder::class,
            PropertyBuildingFacilitySeeder::class,
            PropertyBuildingFacilityAllSeeder::class,
            PropertyRoomFurnitureSeeder::class,
            PropertyRoomFurnitureGroupSeeder::class,
            PropertyCheckInNoteSeeder::class,
            PropertyDepositNoteSeeder::class,
            PropertyUnitDetailSeeder::class,
            PropertyNearbyPlaceSeeder::class,
            PropertyGuestMediaSeeder::class,
            PropertyBuildingUnitSeeder::class,

            // Hotel module
            HotelPolicySeeder::class,
            HotelScoreComponentSeeder::class,
            HotelFacilityGroupSeeder::class,
            HotelTransportPointSeeder::class,
            HotelFaqSeeder::class,
            HotelReviewQuoteSeeder::class,

            // Room types
            RoomTypeMediaSeeder::class,
            RoomTypeFacilitySeeder::class,

            // Transaksional
            PropertySearchLogSeeder::class,
            PropertyRecommendationSeeder::class,
            PropertyQuestionSeeder::class,
        ]);
    }
}
